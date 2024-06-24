#import "@preview/touying:0.4.2": *
#import "@preview/pinit:0.1.4": *
#import "@preview/xarrow:0.3.0": xarrow
#import "psi.typ"

// color-scheme can be navy-red, blue-green, or pink-yellow
#let s = psi.register(aspect-ratio: "16-9", color-scheme: "pink-yellow")

#let s = (s.methods.info)(
  self: s,
  title: [Making Koopmans functionals accessible],
  subtitle: [],
  author: [Edward Linscott],
  date: datetime(year: 2024, month: 6, day: 25),
  location: [MARVEL Pillar IV Meeting],
  references: [references.bib],
)
#let blcite(reference) = {
  set text(white)
  cite(reference)
}

#set footnote.entry(clearance: 0em)
#show bibliography: set text(0.6em)

// // Hack to handle enum and list
// #let s = (s.methods.update-cover)(self: s, body => box(scale(x: 0%, body)))

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

== A powerful tool for computational spectroscopy

#grid(
  columns: (4fr, 1fr, 2fr, 1fr),
  rows: (auto, auto, auto, auto),
  align: (horizon + right, horizon + left, horizon + right, horizon + left),
  gutter: 1em,
  grid.cell(image("figures/colonna_2019_gw100_ip.jpeg", height: 30%)),
  text("ionisation potentials", size: 0.8em) + cite(<Colonna2019>),
  grid.cell(image("figures/fig_nguyen_prx_bandgaps.png", height: 30%)),
  text("band gaps", size: 0.8em) + cite(<Nguyen2018>),
  grid.cell(image("figures/fig_nguyen_prl_spectra.png", height: 25%)),
  text("photoemission spectra", size: 0.8em) + cite(<Nguyen2015>),
  grid.cell(image("figures/marrazzo_CsPbBr3_bands.svg", height: 30%)),
  text("spin-orbit coupling", size: 0.8em) + cite(<Marrazzo2024>),
)

== Koopmans functional theory

$
  E^"KI"_bold(alpha) [rho, {rho_i}] = &
  E^"DFT" [rho]
  \ & +
  sum_i alpha_i {
    - underbrace((E^"DFT" [rho] - E[rho^(f_i arrow.r 0)]), "remove non-linear dependence")
    + underbrace(f_i (E^"DFT" [rho^(f_i arrow.r 1)] - E^"DFT" [rho^(f_i arrow.r 0)]), "restore linear dependence")
  }
$

#pause

Powerful but complex:
- minimisation gives rise to localised orbitals, so we want to first Wannierise to initialise (or even define) these orbitals #pause
- screening parameters account for orbital relaxation, should be calculated #emph[ab initio], and this is expensive

==
#align(center, image(width: 50%, "figures/koopmans_grey_on_transparent.png"))

An ongoing effort to make Koopmans functional calculations straightforward for non-experts@Linscott2023

- straightforward installation
- automated workflows
- minimal input required of the user #pause

For more details, go to `koopmans-functionals.org`

#matrix-slide(title: "Making Koopmans functionals accessible")[
  #image("figures/black_box_filled_square.png")
][
  + automated Wannerisation #pause
  + calculating the screening parameters via machine learning #pause
  + integration with `AiiDA`
]

= Automated Wannierisation

== The three pillars of automated Wannierisation

#grid(
  columns: (2fr, 2fr, 3fr),
  align: center + horizon,
  gutter: 1em,
  image("figures/proj_disentanglement_fig1a.png", height: 60%),
  image("figures/new_projs.png", height: 60%),
  image("figures/target_manifolds_fig1b.png", height: 60%),

  text("projectability-based disentanglement") + cite(<Qiao2023>),
  text("use PAOs found in pseudopotentials"),
  text("parallel transport to separate manifolds") + cite(<Qiao2023a>),
)

== Example 1: TiO#sub[2]
#grid(
  columns: (1fr, 1fr),
  align: center + horizon,
  gutter: 1em,
  image("figures/TiO2_wannierize_bandstructure.png", height: 80%),
  text(size: 0.6em, raw(read("scripts/tio2.json"), block: true, lang: "json")),
)

== Example 2: LiF
#slide[
  #image("figures/default.png", height: 80%)
][
  #uncover("2-", image("figures/Li_only.png", height: 80%))
]


= Electronic screening via machine learning

== Electronic screening via machine learning

A key ingredient of Koopmans functional calculations are the screening parameters:

$
  alpha_i = (angle.l n_i mid(|) epsilon^(-1) f_"Hxc" mid(|) n_i angle.r) / (angle.l n_i mid(|) f_"Hxc" mid(|) n_i angle.r)
$

- a local measure of the degree by which electronic interactions are screened #pause
- one screening parameter per (non-equivalent) orbital #pause
- must be computed #emph[ab intio] via $Delta$SCF@Nguyen2018@DeGennaro2022a or DFPT@Colonna2018@Colonna2022 #pause
- corresponds to the vast majority of the computational cost of Koopmans functional calculation

== The machine-learning framework

#align(
  center,
  grid(
    columns: 5,
    align: horizon,
    gutter: 1em,
    image("figures/orbital.emp.00191_cropped.png", height: 50%),
    xarrow("power spectrum decomposition"),
    $vec(delim: "[", x_0, x_1, x_2, dots.v)$,
    xarrow("ridge regression"),
    $alpha_i$,
  ),
)

$
  c^i_(n l m, k) & = integral dif bold(r) g_(n l) (r) Y_(l m)(theta,phi) n^i (
    bold(r) - bold(R)^i
  )
$


$
  p^i_(n_1 n_2 l,k_1 k_2) = pi sqrt(8 / (2l+1)) sum_m c_(n_1 l m,k_1)^(i *) c_(n_2 l m,k_2)^i
$

== Two test systems

#align(
  center,
  grid(
    columns: 2,
    align: horizon + center,
    gutter: 1em,
    image("figures/water.png", height: 70%),
    image("figures/CsSnI3_disordered.png", height: 70%),

    "water", "CsSnI" + sub("3"),
  ),
)

== Results

#slide[
  #image(
    "figures/water_cls_calc_vs_pred_and_hist_bottom_panel.svg",
    width: 100%,
  )
  #blcite(<Schubert2024>)
]

#slide[
  #image("figures/CsSnI3_calc_vs_pred_and_hist_bottom_panel.svg", width: 100%)
  #blcite(<Schubert2024>)
]

#slide[
  #align(
    center + horizon,
    image(
      "figures/convergence_analysis_side_by_side.svg",
      width: 100%,
    ) + "accurate to within " + $cal("O")$ + "(10 meV) " + emph("cf.") + " typical band gap accuracy of " + $cal("O")$ + "(100 meV)",
  )
  #blcite(<Schubert2024>)
]

#slide[
  #align(
    center + horizon,
    image(
      "figures/speedup.svg",
      height: 70%,
    ) + "speedup of " + $cal("O")$ + "(10) to " + $cal("O")$ + "(100)",
  )
  #blcite(<Schubert2024>)
]


= Integration with `AiiDA`

== Integration with `AiiDA`

Work is ongoing to interface `koopmans` with `AiiDA`, which would allow for...

- remote execution #pause
- parallel execution #pause
- making use of `AiiDA`'s workflows #pause
- deployment as a GUI (see Miki Bonacci's talk immediately after this one)

#pause

The strategy we are employing...
- requires a moderate amount of refactoring #pause
- will not change `koopmans`' user interface

= Summary

== Summary
#grid(
  columns: (1fr, 2fr),
  gutter: 1em,
  image("figures/black_box_filled_square.png", width: 100%),
  text[
    Koopmans functionals are
    - a powerful tool for computational spectroscopy, and
    - are increasingly user-friendly:
      - Wannierisation is more black-box @Qiao2023@Qiao2023a
      - machine learning can be used to calculate the screening parameters @Schubert2024
      - parallel and remote execution with `AiiDA` is on the horizon
      - GUI development is also underway (up next!)
  ],
)

== Acknowledgements
#align(
  center,
  grid(
    columns: 5,
    align: horizon + center,
    gutter: 1em,
    image("media/mugshots/nicola_marzari.jpg", height: 45%),
    image("media/mugshots/nicola_colonna.png", height: 45%),
    image("media/mugshots/junfeng_qiao.jpeg", height: 45%),
    image("media/mugshots/yannick_schubert.jpg", height: 45%),
    image("media/mugshots/miki_bonacci.jpg", height: 45%),

    text("Nicola Marzari"),
    text("Nicola Colonna"),
    text("Junfeng Qiao"),
    text("Yannick Schubert"),
    text("Miki Bonacci"),
  ),
)

#align(
  center,
  grid(
    columns: 2,
    align: horizon + center,
    gutter: 2em,
    image("media/logos/snf_color_on_transparent.png", height: 20%),
    image("media/logos/marvel_color_on_transparent.png", height: 20%),
  ),
)

= Spare slides
== Koopmans functional basics

How do we calculate the energies of charged excitations? And why does DFT fail?

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

== References
#bibliography("references.bib")