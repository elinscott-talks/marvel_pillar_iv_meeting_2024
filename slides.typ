#import "@preview/touying:0.4.2": *
#import "@preview/pinit:0.1.4": *
#import "psi.typ"

// color-scheme can be navy-red, blue-green, or pink-yellow
#let s = psi.register(aspect-ratio: "16-9", color-scheme: "pink-yellow")

#let s = (s.methods.info)(
  self: s,
  title: [Making Koopmans functionals friendlier],
  subtitle: [],
  author: [Edward Linscott],
  date: datetime(year: 2024, month: 6, day: 25),
  location: [MARVEL Pillar IV Meeting],
)

#let (init, slides) = utils.methods(s)
#show: init

#let (
  slide,
  empty-slide,
  title-slide,
  new-section-slide,
  focus-slide,
  matrix-slide,
) = utils.slides(s)
#show: slides

== Outline
- a brief recap of Koopmans functionals and the `koopmans` code
- recent progress making `koopmans` friendlier
  - automated Wannierisation
  - screening via machine learning
  - integration with `AiiDA`

= Koopmans functionals

== Koopmans functionals

How do we calculate the energies of charged excitations? And why does DFT fail?

#pause

The exact Green's function has poles that correspond to total energy differences

$
  ε_i = cases(E(N) - E_i (N-1) & "if" i in "occ", E_i (N+1) - E(N) & "if" i in "emp")
$

but DFT does #emph[not]

#focus-slide()[Core idea: impose this condition to DFT to improve its description of spectral properties]

#matrix-slide()[
  Formally, every orbital $i$ should have an eigenenergy
  $
    epsilon_i^"Koopmans" = ⟨
      phi_i mid(|)hat(H)mid(|)phi_i
    ⟩ = frac(dif E, dif f_i)
  $
  that is
  - independent of $f_i$
  - equal to $Delta E$ of explicit electron addition/removal
][
  #image(width: 100%, "figures/fig_en_curve_gradients_zoom.svg")
]

$
  E^"KI"_bold(alpha) [rho, {rho_i}] = &
  E^"DFT" [rho]
  \ & +
  sum_i alpha_i {
    - underbrace((E^"DFT" [rho] - E[rho^(f_i arrow.r 0)]), "remove non-linear dependence")
    + underbrace(f_i (E^"DFT" [rho^(f_i arrow.r 1)] - E^"DFT" [rho^(f_i arrow.r 0)]), "restore linear dependence")
  }
$

Powerful but complex:
- minimisation gives rise to localised orbitals, so we want to first Wannierise to initialise (or even define) these orbitals
- screening parameters account for orbital relaxation, should be calculated #emph[ab initio], and this is expensive

== The `koopmans` package
#align(center, image(width: 50%, "figures/koopmans_grey_on_transparent.png"))

An ongoing effort to make Koopmans functional calculations straightforward for non-experts@Linscott2023

#matrix-slide[
  #image("figures/black_box_filled_square.png")
][
]
#par(justify: true)[#lorem(200)]

#focus-slide()[Here is a focus slide presenting a key idea]


More text appears under the same subsection title as earlier

== New Subsection
But a new subsection starts a new page

#bibliography("references.bib", title: none, style: "custom.csl")