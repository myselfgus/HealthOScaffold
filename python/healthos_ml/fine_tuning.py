from dataclasses import dataclass
from pathlib import Path


@dataclass
class FineTuningJob:
    job_name: str
    base_model: str
    dataset_ref: str
    adapter_name: str


def stage_job(job: FineTuningJob, root: Path) -> Path:
    job_dir = root / "models" / "adapters" / job.adapter_name
    job_dir.mkdir(parents=True, exist_ok=True)
    manifest = job_dir / "job.txt"
    manifest.write_text(
        f"job_name={job.job_name}\nbase_model={job.base_model}\ndataset_ref={job.dataset_ref}\n",
        encoding="utf-8",
    )
    return manifest
