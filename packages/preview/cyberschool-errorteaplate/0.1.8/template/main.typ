#import "@preview/cyberschool-errorteaplate:0.1.8": *
#show: conf.with(
  title: "Title",
  pre-title: "Pre-title",
  authors: (
    (
      name: "name",
      affiliation: "affiliation",
      email: "email",
    ),
  ),
  logos: (
    image.with("assets/Logo_univ_rennes.png"),
    image.with("assets/Logo_cyberschool.png"),
  ),
  abstract: "abstract text",
  outline-title: "Contents",
  outline-level: 3,
)

= Hello, world !
== Hello, world !
=== Hello, world !
