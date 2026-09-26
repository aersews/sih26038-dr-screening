# Security Policy

## Reporting

Report suspected vulnerabilities privately to the repository maintainers through GitHub's private vulnerability reporting feature. Do not open a public issue containing credentials, patient data, exploitable details, or unreleased model/data material.

## Data handling

- Do not commit `.env` files, API keys, `kaggle.json`, private keys, or access tokens.
- Do not commit patient-identifiable information or raw retinal datasets without documented authorization.
- Obtain and store datasets outside this repository under their original terms.
- Treat generated reports and model outputs as research artifacts, not diagnostic records.

## Scope

This repository is a research prototype. Security issues include credential exposure, unauthorized dataset redistribution, unsafe execution paths, and misleading deployment guidance. It is not a certified clinical system.
