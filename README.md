# osac-ai-skills

Dedicated repository for OSAC AI skills and the tooling that only exists to
support or validate them:

- Native Agent Skills under `skills/`
- Skillsaw lint config and CI (`.skillsaw.yaml`, `.github/workflows/`)
- Generic agent skill fan-out (`tools/link-agent-skills.sh`)
- Skill-quality eval harness (`evals/`)

This is the skills content store. Bootstrap/orchestration (what to clone and
when) lives in consumer repos — primarily `osac/tools/bootstrap.sh`, and
until cutover also `osac-workspace/bootstrap.sh`. `flightctl/ai-workflows`
remains a separate vendored dependency of those consumers; it is not hosted
here.

## Background

See ADR 0001 in `osac-project/osac-workspace`:
`decisions/0001-dedicated-ai-skills-repo.md`.
