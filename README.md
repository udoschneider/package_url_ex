# PackageUrl

<!-- MODULEDOC -->

A [PackageUrl](https://github.com/package-url/purl-spec) library in pure Elixir.

The current implementation fully passes the test suites from the official
[purl-spec](https://raw.githubusercontent.com/package-url/purl-spec/master/test-suite-data.json)
and from the [javascript
implementation](https://raw.githubusercontent.com/package-url/packageurl-js/master/test/data/test-suite-data.json).
It also supports custom sanitization/validation as defined in
https://github.com/package-url/purl-spec/blob/master/PURL-TYPES.rst for the
following packages:
- `alpm`
- `bitbucket`
- `cargo`
- `cocoapods`
- `composer`
- `conan`
- `conda`
- `cran`
- `deb`
- `docker`
- `gem`
- `generic`
- `github`
- `golang`
- `hackage`
- `hex`
- `maven`
- `npm`
- `nuget`
- `oci`
- `pub`
- `pypi`
- `swid`
- `swift`

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `package_url` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:package_url, "~> 0.1.0"}
  ]
end
```

## Basic Usage

```elixir
iex> purl = PackageUrl.new!("pkg:maven/org.apache.commons/io@1.3.4")       
%PackageUrl{
  name: "io",
  namespace: "org.apache.commons",
  qualifiers: nil,
  scheme: "pkg",
  subpath: nil,
  type: "maven",
  version: "1.3.4"
}
iex> PackageUrl.to_string!(purl)
"pkg:maven/org.apache.commons/io@1.3.4"
```

<!-- MODULEDOC -->

Documentation can be generated with
[ExDoc](https://github.com/elixir-lang/ex_doc) and published on
[HexDocs](https://hexdocs.pm). Once published, the docs can be found at
<https://hexdocs.pm/package_url>.

## License

PackageUrl is released under the MIT License - see the [LICENSE](LICENSE)
file.
