import csv
import glob
import json
import os

os.makedirs("clinical_warehouse", exist_ok=True)

# Exclude facility and provider metadata files to isolate patient-level bundles
files = [
    f for f in glob.glob("**/*.json", recursive=True)
    if "hospital" not in f.lower() and "practitioner" not in f.lower()
]

with open("clinical_warehouse/patients.csv", "w", newline="", encoding="utf-8") as f_pat, \
     open("clinical_warehouse/conditions.csv", "w", newline="", encoding="utf-8") as f_cond, \
     open("clinical_warehouse/medications.csv", "w", newline="", encoding="utf-8") as f_med, \
     open("clinical_warehouse/lab_results.csv", "w", newline="", encoding="utf-8") as f_lab:

    pat_writer = csv.writer(f_pat)
    cond_writer = csv.writer(f_cond)
    med_writer = csv.writer(f_med)
    lab_writer = csv.writer(f_lab)

    pat_writer.writerow(["patient_id", "gender", "birth_date", "city", "state"])
    cond_writer.writerow(["patient_id", "condition", "onset_date", "abatement_date", "clinical_status"])
    med_writer.writerow(["patient_id", "medication", "authored_date", "status"])
    lab_writer.writerow(["patient_id", "test_name", "value", "unit", "effective_date"])

    for file_path in files:
        with open(file_path, "r", encoding="utf-8") as f:
            bundle = json.load(f)

        # Normalize file path separators across Windows and Unix to extract clean patient ID
        patient_id = file_path.split("\\")[-1].split("/")[-1].replace(".json", "")

        for entry in bundle.get("entry", []):
            res = entry.get("resource", {})
            rtype = res.get("resourceType")

            if rtype == "Patient":
                gender = res.get("gender", "unknown")
                birth_date = res.get("birthDate", "unknown")
                # FHIR stores addresses as a list; default to [{}] to prevent IndexError if missing
                address = res.get("address", [{}])[0]
                pat_writer.writerow([patient_id, gender, birth_date, address.get("city", ""), address.get("state", "")])

            elif rtype == "Condition":
                text = res.get("code", {}).get("text", "")
                if "(disorder)" in text:
                    # Slice ISO-8601 timestamps to YYYY-MM-DD for clean SQL date casting in Athena
                    onset = res.get("onsetDateTime", "")[:10]
                    abatement = res.get("abatementDateTime", "")[:10]
                    status = res.get("clinicalStatus", {}).get("coding", [{}])[0].get("code", "unknown")
                    cond_writer.writerow([patient_id, text, onset, abatement, status])

            elif rtype == "MedicationRequest":
                med_name = res.get("medicationCodeableConcept", {}).get("text", "")
                authored = res.get("authoredOn", "")[:10]
                status = res.get("status", "unknown")
                if med_name:
                    med_writer.writerow([patient_id, med_name, authored, status])

            elif rtype == "Observation":
                # Filter strictly for numeric valueQuantity records (skips text-only survey responses)
                val_qty = res.get("valueQuantity")
                if val_qty and "value" in val_qty:
                    test_name = res.get("code", {}).get("text", "")
                    eff_date = res.get("effectiveDateTime", "")[:10]
                    lab_writer.writerow([patient_id, test_name, val_qty.get("value"), val_qty.get("unit", ""), eff_date])

print("Clinical warehouse CSVs generated successfully!")