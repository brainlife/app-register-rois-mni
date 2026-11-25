<h1 align="center">register rois mni</h1>

<p align="center">
  Applies an existing FSL nonlinear warp to move ROIs between an ACPC-aligned T1-weighted image space and a standard template with FSL applywarp.
</p>

<p align="center">
  <a href="https://github.com/brainlife/abcd-spec"><img src="https://img.shields.io/badge/ABCD_Spec-v1.1-green.svg" alt="ABCD Spec v1.1"></a>
  <a href="https://doi.org/10.25663/brainlife.app.727"><img src="https://img.shields.io/badge/Brainlife-brainlife.app.727-blue.svg" alt="Run on brainlife.io"></a>
  <a href="https://github.com/brainlife/app-register-rois-mni/blob/master/LICENSE"><img src="https://img.shields.io/badge/License-MIT-lightgrey.svg" alt="MIT license"></a>
</p>

> **This branch, `visual-white-matter-rois-v1.0`, is the brainlife.io App Warp ROIs for Visual White Matter From MNI to T1 space** ([doi:10.25663/brainlife.app.727](https://doi.org/10.25663/brainlife.app.727)). The other Apps in this repository are listed under **Versions on brainlife.io** below.

## At a glance

<!-- brainlife-app:begin (generated from the App manifest; edit the manifest, not this block) -->

> **Registers a T1-weighted image to the MNI152 2 mm template with FSL flirt and fnirt and warps bundled visual-system ROIs (LGN, pulvinar, superior colliculus, V1, anterior V1, V5) into the subject's T1 space.**

Computes a linear (flirt) and nonlinear (fnirt) registration from the T1w image to MNI152 2 mm, inverts the warp, and applies it to twelve left/right template ROIs shipped with the App (LGN, pulvinar, superior colliculus, V1, anterior V1, V5), then binarizes them. Use it to obtain visual white matter tracking ROIs in subject space without supplying ROIs. Template and interpolation are fixed in the code (MNI152_2mm, nearest neighbour).

| | |
|---|---|
| **Inputs** | `neuro/anat/t1w` |
| **Outputs** | `raw` · `neuro/rois` |
| **Container** | `brainlife/fsl:6.0.4-patched2` |
| **Resources** | 4 CPUs · 6.5 h walltime |
| **Run it** | [doi.org/10.25663/brainlife.app.727](https://doi.org/10.25663/brainlife.app.727) |

#### Inputs

| Input | Datatype | Required | Description |
|---|---|---|---|
| `t1` | `neuro/anat/t1w` | yes | The path to the anat/t1w datatype |

#### Outputs

| Output | Datatype | Description |
|---|---|---|
| `raw` | `raw` | Output directory for all the data derivatives generated |
| `rois` | `neuro/rois` | Binarized visual-system ROIs (left/right LGN, pulvinar, superior colliculus, V1, anterior V1, V5) in the subject's T1 space. |

<details>
<summary><b>Parameters</b> (3)</summary>

| Parameter | Type | Default | Description |
|---|---|---|---|
| `input_type` | enum | `T1` | This controls the datatype (T1 or T2) to use. This should not be changed. Only used to keep the github repository between the two apps the same Options: `T1`. |
| `template` | enum | `MNI152_2mm` | Template setting; the code hardcodes MNI152_2mm regardless of this value. Options: `MNI152_2mm`. |
| `interp` | enum | `nn` | Interpolation setting; the code hardcodes nearest neighbour regardless of this value. Options: `nn`. |

</details>

<!-- brainlife-app:end -->

## Versions on brainlife.io

This repository hosts several Apps, each built from its own branch.

| App | Branch | Run it | Status |
|---|---|---|---|
| Apply warp to or from standard space to ROIs (T1w) - ACPC T1 space | [`v1.1`](https://github.com/brainlife/app-register-rois-mni/tree/v1.1) | [doi:10.25663/brainlife.app.813](https://doi.org/10.25663/brainlife.app.813) | current |
| Apply warp to or from standard space to bundle masks (T1w) - ACPC T1 space | [`bundle-masks-v1.1`](https://github.com/brainlife/app-register-rois-mni/tree/bundle-masks-v1.1) | [doi:10.25663/brainlife.app.805](https://doi.org/10.25663/brainlife.app.805) | available |
| **Warp ROIs for Visual White Matter From MNI to T1 space** (this branch) | [`visual-white-matter-rois-v1.0`](https://github.com/brainlife/app-register-rois-mni/tree/visual-white-matter-rois-v1.0) | [doi:10.25663/brainlife.app.727](https://doi.org/10.25663/brainlife.app.727) | available |
| Apply warp to or from standard space to ROIs (T2w) - ACPC T2 space | [`v1.1`](https://github.com/brainlife/app-register-rois-mni/tree/v1.1) | [doi:10.25663/brainlife.app.718](https://doi.org/10.25663/brainlife.app.718) | available |
| Apply warp to or from standard space to ROIs (T2w) - Scanner T2 space | [`v1.1`](https://github.com/brainlife/app-register-rois-mni/tree/v1.1) | [doi:10.25663/brainlife.app.717](https://doi.org/10.25663/brainlife.app.717) | available |
| Apply warp to or from standard space to ROIs (T1w) - ACPC T1 space | [`v1.1`](https://github.com/brainlife/app-register-rois-mni/tree/v1.1) | [doi:10.25663/brainlife.app.716](https://doi.org/10.25663/brainlife.app.716) | available |
| Apply warp to or from standard space to ROIs (T1w) - Scanner T1 space | [`v1.1`](https://github.com/brainlife/app-register-rois-mni/tree/v1.1) | [doi:10.25663/brainlife.app.715](https://doi.org/10.25663/brainlife.app.715) | available |
| Compute and Apply warp from subject-to-standard space to ROIs (T1w) | [`1.0`](https://github.com/brainlife/app-register-rois-mni/tree/1.0) | [doi:10.25663/brainlife.app.670](https://doi.org/10.25663/brainlife.app.670) | available |
| Apply warp from subject-to-standard space to ROIs (T2w) | [`1.0`](https://github.com/brainlife/app-register-rois-mni/tree/1.0) | [doi:10.25663/brainlife.app.667](https://doi.org/10.25663/brainlife.app.667) | deprecated |

## Running the App

### On brainlife.io

Open the App at [doi.org/10.25663/brainlife.app.813](https://doi.org/10.25663/brainlife.app.813), choose `neuro/anat/t1w`, `neuro/rois`, `neuro/transform/nifti` from your project and press **Execute**. The results are saved to your project as `raw`, `neuro/rois`.

### Locally

You need [Singularity/Apptainer](https://apptainer.org/) (the App runs in `brainlife/fsl:6.0.4-patched2`), [`jq`](https://jqlang.github.io/jq/).

1. Clone this repository and check out the App's branch (`git checkout v1.1`).
2. Create `config.json` with the paths to your inputs and the parameters:

   ```json
   {
       "t1": "/path/to/id-anat-t1w/t1",
       "rois": "/path/to/id-neuro-rois/rois",
       "label": "/path/to/id-neuro-rois/label",
       "warp": "/path/to/id-neuro-transform-nifti/warp",
       "inverse-warp": "/path/to/id-neuro-transform-nifti/inverse-warp",
       "affine": "/path/to/id-neuro-transform-nifti/affine"
   }
   ```

3. Run `./main`.

## Citing

If you use this App, please cite it, the software it builds on and brainlife.io:

- Warp ROIs for Visual White Matter From MNI to T1 space. brainlife.io App. [doi:10.25663/brainlife.app.727](https://doi.org/10.25663/brainlife.app.727)
- Jenkinson et al. FSL. *NeuroImage* 62:782-790 (2012). [doi:10.1016/j.neuroimage.2011.09.015](https://doi.org/10.1016/j.neuroimage.2011.09.015)
- Hayashi S, Caron BA, Heinsfeld AS, et al. brainlife.io: a decentralized and open-source cloud platform to support neuroscience research. *Nature Methods* 21:809–813 (2024). [doi:10.1038/s41592-024-02237-2](https://doi.org/10.1038/s41592-024-02237-2)
- Avesani P, McPherson B, Hayashi S, et al. The open diffusion data derivatives, brain data upcycling via integrated publishing of derivatives and reproducible open cloud services. *Scientific Data* 6:69 (2019). [doi:10.1038/s41597-019-0073-y](https://doi.org/10.1038/s41597-019-0073-y)

## Authors

brainlife.io team

## Funding

[![Wellcome-226486/Z/22/Z](https://img.shields.io/badge/Wellcome-226486%2FZ%2F22%2FZ-purple.svg)](https://wellcome.org/)
[![NIH-NINDS-U24NS140384](https://img.shields.io/badge/NIH_NINDS-U24NS140384-green.svg)](https://reporter.nih.gov/project-details/11261037)
[![NIH-NINDS-UM1NS132207](https://img.shields.io/badge/NIH_NINDS-UM1NS132207-green.svg)](https://reporter.nih.gov/project-details/11411328)
[![NIH-NIBIB-R01EB029272](https://img.shields.io/badge/NIH_NIBIB-R01EB029272-green.svg)](https://reporter.nih.gov/project-details/10262925)
[![NIH-NIBIB-R01EB030896](https://img.shields.io/badge/NIH_NIBIB-R01EB030896-green.svg)](https://reporter.nih.gov/project-details/10428625)
[![NIH-NIMH-R01MH126699](https://img.shields.io/badge/NIH_NIMH-R01MH126699-green.svg)](https://reporter.nih.gov/project-details/10460628)
[![NIH-NIDCD-R01DC020088](https://img.shields.io/badge/NIH_NIDCD-R01DC020088-green.svg)](https://reporter.nih.gov/project-details/11140284)
[![NSF-BCS-1734853](https://img.shields.io/badge/NSF_BCS-1734853-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=1734853)
[![NSF-BCS-2203524](https://img.shields.io/badge/NSF_BCS-2203524-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=2203524)
[![NSF-IIS-1636893](https://img.shields.io/badge/NSF_IIS-1636893-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=1636893)
[![NSF-OAC-2148729](https://img.shields.io/badge/NSF_OAC-2148729-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=2148729)
[![NSF-IIS-1912270](https://img.shields.io/badge/NSF_IIS-1912270-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=1912270)
[![NSF-IIS-2148700](https://img.shields.io/badge/NSF_IIS-2148700-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=2148700)
[![NSF-OAC-1916518](https://img.shields.io/badge/NSF_OAC-1916518-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=1916518)

<sub>brainlife.io is publicly funded, and acknowledging that support helps keep it running. This App was developed with support from Wellcome, the U.S. National Institutes of Health (including the BRAIN Initiative BRAIN CONNECTS program: The Axonal Projectome EXchange, U24NS140384, and the Center for Mesoscale Connectomics, UM1NS132207) and the U.S. National Science Foundation.</sub>

## License

See [LICENSE](https://github.com/brainlife/app-register-rois-mni/blob/master/LICENSE).
