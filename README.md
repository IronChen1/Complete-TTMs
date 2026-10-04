
# Complete-TTMs

Complete total-transmission modes (TTMs) of Kerr black holes.

The dataset and codes are developed and maintained by **Changkai Chen**.

The TTM dataset will be continuously updated.

## How to cite

If you use this dataset or the accompanying codes, please cite:

```text
@article{Chen:2026ane,
    author = "Chen, Changkai and Zhang, Xiaohua and Cao, Zhoujian and Jing, Jiliang and Long, Sheng",
    title = "{Complete total-transmission modes of Kerr black holes}",
    eprint = "2609.39609",
    archivePrefix = "arXiv",
    primaryClass = "gr-qc",
    month = "9",
    year = "2026"
}

## Repository structure

```text
Complete-TTMs/
├── Data/
│   ├── TTM_merged_Ninf1_M*.mat
│   ├── TTM_merged_Ninf2_M*.mat
│   ├── TTM_merged_Ninf3_M*.mat
│   └── TTM_merged_Ninf4_M*.mat
│
├── Codes/
│   ├── MATLAB/
│   │   └── plotting codes
│   │
│   └── Mathematica/
│       └── example_TTM_FindRoot.nb
│
└── README.md
```

The four TTM families are labeled by

\[
n_\infty = 1,2,3,4.
\]

The azimuthal index is specified by `M` in the filename. For example,

```text
TTM_merged_Ninf3_M7.mat
```

contains the \(n_\infty=3\), \(m=7\) TTM sequences.

## Data structure

Each MATLAB `.mat` file contains a cell array with the structure

```matlab
C{j,1} = [ell, m];
C{j,2} = [a, omega, lambda];
```

where each row of `C{j,2}` is

```text
[a, omega, lambda]
```

with

- `a`: dimensionless Kerr spin parameter,
- `omega`: complex TTM frequency,
- `lambda`: complex angular separation constant,
- `ell`: polar mode index,
- `m`: azimuthal mode index.

Thus, for a given \((\ell,m)\),

```matlab
a      = C{j,2}(:,1);
omega  = C{j,2}(:,2);
lambda = C{j,2}(:,3);
```

The data are organized separately for the four \(n_\infty\) families.

## Visualization

MATLAB plotting codes are provided in `Codes/MATLAB/`.

The TTM frequency spectra are visualized using

\[
\Re(\omega), \qquad -\Im(\omega),
\]

with the Kerr spin \(a\) represented by color.

The separation constants can similarly be visualized using

\[
\Re(\lambda), \qquad -\Im(\lambda).
\]

The default plots use the original linear coordinates. Logarithmic coordinates can also be selected for the divergent TTM families.

For the \(m=0\) sector, the \(n_\infty=2\) and \(n_\infty=3\) sequences can overlap strongly in a two-dimensional projection. These families are therefore displayed as three-dimensional scatter plots,

\[
\bigl(\Re(\omega),-\Im(\omega),\ell\bigr),
\]

with \(\ell\) used as the third coordinate. The \(n_\infty=1\) and \(n_\infty=4\) families can be displayed directly in two dimensions.

For logarithmic frequency plots:

- \(n_\infty=1\): \(-\Re(\omega)\) and \(-\Im(\omega)\) are shown on logarithmic axes;
- \(n_\infty=2,4\): \(\Re(\omega)\) and \(-\Im(\omega)\) are shown on logarithmic axes;
- \(n_\infty=3\): \(\Re(\omega)\) remains on a linear axis, while \(-\Im(\omega)\) may be shown on a logarithmic axis.

## Example: computing a TTM

A Mathematica example is provided in

```text
Codes/Mathematica/example_TTM_FindRoot.nb
```

The notebook demonstrates how to solve the two TTM conditions

```mathematica
HCTTMKerrYChen[omega, lambda, s, a, m] == {0, 0}
```

using high-precision `FindRoot`.

The user specifies

```mathematica
nInf = 3;   (* TTM family *)
ell = 32;   (* polar index *)
m = 7;      (* azimuthal index *)
a0 = 1;     (* target Kerr spin *)
```

and the notebook automatically loads the corresponding dataset,

```text
Data/TTM_merged_Ninf3_M7.mat
```

selects the required \((\ell,m)\) sequence, and uses the data point nearest to `a0` as the initial guess.

To make the example independent of the stored high-precision solution, the initial values of \(\omega\) and \(\lambda\) are rounded to five decimal places before calling `FindRoot`.

The numerical solution is then verified through the residual

\[
\max\left(|F_1|,|F_2|\right),
\]

where \(F_1=F_2=0\) are the two TTM equations implemented in `HCTTMKerrYChen`.

## Requirements

### MATLAB

Used for loading the datasets and producing the visualizations.

### Wolfram Mathematica

Used for the high-precision TTM root-finding example. The calculation uses `HeunC` and `HeunCPrime`.


