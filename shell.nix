{ pkgs ? import <nixpkgs> { } }:

let
  inherit (pkgs) stdenv lib;

  pagefind = stdenv.mkDerivation {
    name = "pagefind";
    # FIXME: compile from source instead (Rust).
    src = pkgs.fetchzip {
      url = https://github.com/CloudCannon/pagefind/releases/download/v0.8.0/pagefind-v0.8.0-x86_64-unknown-linux-musl.tar.gz;
      hash = "sha256-GpAQxxWVnjjJEtXSnywgAUUMPHESkvexyoumYHXwZCU=";
    };
    installPhase = ''
      install -Dm755 pagefind $out/bin/pagefind
    '';
  };

  build-search-docs = pkgs.writeShellApplication {
    name = "build-search-docs";
    runtimeInputs = with pkgs; [ yq coreutils ];
    text = ''
      mkdir -p "$2"
      for f in "$1"/**/*.gpx; do
        hash="$(sha1sum "$f" | cut -c1-40)"
        # shellcheck disable=SC2002
        cat "$f" | xq | jq --arg f "$(basename "$f")" --arg hash "$hash" \
          '{"body": {"h1": {"#text": .gpx.trk.name, "@data-fname": $f, "@data-id": $hash, "@data-started": .gpx.trk.trkseg.trkpt[0].time, "@data-pagefind-meta": "started[data-started], fname[data-fname], id[data-id]"}}}' | \
          yq -c -x > "$2/$hash.html"
      done
    '';
  };

  gen-search-index = pkgs.writeShellApplication {
    name = "gen-search-index";
    runtimeInputs = [ pagefind build-search-docs ];
    text = ''
      tmp=$(mktemp -d)
      ( cd "$tmp"
        build-search-docs "$1" "$tmp"
        pagefind -v -b "$2" --force-language en --root-selector body -s "$tmp"
      ) || true
      rm -rf "$tmp"
    '';
  };

  to-geojson = pkgs.writeShellApplication {
    name = "to-geojson";
    runtimeInputs = with pkgs; [ gdal coreutils ];
    text = ''
      name=$(sha1sum "$1" | cut -c1-40);
      ogr2ogr -f GeoJSON "$name.json" "$1" \
        -sql 'select '"'$name'"' as name from tracks' \
        -lco WRITE_BBOX=YES
    '';
  };

  gpx-to-pbf = pkgs.writeShellApplication {
    name = "gpx-to-pbf";
    runtimeInputs = with pkgs; [ tippecanoe gdal parallel coreutils to-geojson ];
    text = let simplify = if true then "-simplify 0.00008" else ""; in
      ''
        tmp=$(mktemp -d)
        ( cd "$tmp"
          # shellcheck disable=SC2016
          LC_ALL=C parallel --will-cite to-geojson '{}' \
            ::: "$1"/**/*.gpx
          tippecanoe -o all.mbtiles -Z 0 -z 15 \
            --use-attribute-for-id=name --force -y name \
            ./*.json
          rm -rf "$2"
          ogr2ogr -f MVT "$2" all.mbtiles -dsco MAXZOOM=15
        ) || true
        rm -rf "$tmp"
      '';
    # mb-util is supposedly deprecated.
    # ${pkgs.mbutil}/bin/mb-util --silent --image_format=pbf all.mbtiles "$2"
  };

in
pkgs.mkShell {
  buildInputs = [
    gpx-to-pbf
    gen-search-index
  ];

  shellHook = ''
  '';
}
