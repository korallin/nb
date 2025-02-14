#!/usr/bin/env bats

load test_helper

# --add #######################################################################

@test "'browse <notebook>:<folder-id>/<folder-id>/ --add' displays header crumbs with '+' unlinked." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/Sample Folder" --type "folder"
  }

  run "${_NB}" browse home:1/1/ --header --add

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    == 0 ]]

  printf "%s\\n" "${output}" | grep -q \
"<nav class=\"header-crumbs\"><strong><a href=\"//localhost:6789/?--limit=.*&--columns=.*\"><span class=\"muted\">❯</span>nb</a> <span class=\"muted\">·</span> "

  printf "%s\\n" "${output}" | grep -q \
" <span class=\"muted\">·</span> <a href=\"//localhost:6789/home:?--limit=.*&--columns=.*\">home</a> <span class=\"muted\">:</span> "

  printf "%s\\n" "${output}" | grep -q \
" <span class=\"muted\">:</span> <a href=\"//localhost:6789/home:1/?--limit=.*&--columns=.*\">Example Folder</a> <span class=\"muted\">/</span> "

  printf "%s\\n" "${output}" | grep -q \
" <span class=\"muted\">/</span> <a href=\"//localhost:6789/home:1/1/?--limit=.*&--columns=.*\">Sample Folder</a> <span class=\"muted\">/</span> "

  printf "%s\\n" "${output}" | grep -q \
" <span class=\"muted\">/</span> <span class=\"muted\">+</span></strong></nav>"

  printf "%s\\n" "${output}" | grep -q -v "↓"
}

# --edit ######################################################################

@test "'browse --edit' with .odt file does not display edit link in header crumbs." {
  {
    "${_NB}" init

    "${_NB}" add  "Example File.md"                 \
      --title     "Example Title"                   \
      --content   "Example content."

    "${_NB}" add  "Example Folder/File One.md"      \
      --title     "Title One"                       \
      --content   "Example content. [[Example Title]]"

    cat "${NB_DIR}/home/Example Folder/File One.md" \
      | pandoc --from markdown --to odt             \
      | "${_NB}" add "Example Folder/File One.odt"

    [[ -f "${NB_DIR}/home/Example Folder/File One.odt" ]]

    sleep 1
  }

  run "${_NB}" browse 2/2 --print --edit

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    ==  0               ]]

  printf "%s\\n" "${output}" | grep     -q \
"<a.* href=\"//localhost:6789/?--limit=.*&--columns=.*\"><span class=\"muted\">❯</span>nb</a> <span class=\"muted\">·</span> "

  printf "%s\\n" "${output}" | grep     -q \
" <span class=\"muted\">·</span> <a.* href=\"//localhost:6789/home:?--limit=.*&--columns=.*\">home</a> <span class=\"muted\">:</span> "

  printf "%s\\n" "${output}" | grep     -q \
" <span class=\"muted\">:</span> <a.* href=\"//localhost:6789/home:2/?--limit=.*&--columns=.*\">Example Folder</a> <span class=\"muted\">/</span> "

  printf "%s\\n" "${output}" | grep     -q \
"</span> <a.* href=\"//localhost:6789/--original/home/Example Folder/File One.odt\">↓</a>"

  printf "%s\\n" "${output}" | grep     -q \
" <span class=\"muted\">/</span> <span class=\"muted\">2</span>"

  printf "%s\\n" "${output}" | grep -v  -q "edit"
}

@test "'browse <notebook>:<folder-id>/<folder-id>/<file-id> --edit' displays header crumbs with linked id and editing message." {
  {
    "${_NB}" init

    "${_NB}" add  "Example Folder/Sample Folder/File One.md"  \
      --title     "Example Title"                             \
      --content   "Example content."
  }

  run "${_NB}" browse home:1/1/1 --header --edit

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    == 0 ]]

  printf "%s\\n" "${output}" | grep -q \
"<nav class=\"header-crumbs\"><strong><a href=\"//localhost:6789/?--limit=.*&--columns=.*\"><span class=\"muted\">❯</span>nb</a> <span class=\"muted\">·</span> "

  printf "%s\\n" "${output}" | grep -q \
" <span class=\"muted\">·</span> <a href=\"//localhost:6789/home:?--limit=.*&--columns=.*\">home</a> <span class=\"muted\">:</span> "

  printf "%s\\n" "${output}" | grep -q \
" <span class=\"muted\">:</span> <a href=\"//localhost:6789/home:1/?--limit=.*&--columns=.*\">Example Folder</a> <span class=\"muted\">/</span> "

  printf "%s\\n" "${output}" | grep -q \
" <span class=\"muted\">/</span> <a href=\"//localhost:6789/home:1/1/?--limit=.*&--columns=.*\">Sample Folder</a> <span class=\"muted\">/</span> "

  printf "%s\\n" "${output}" | grep -q \
"</span> <a href=\"//localhost:6789/home:1/1/1?--limit=.*&--columns=.*\">1</a> <span class=\"muted\">·</span> "

  printf "%s\\n" "${output}" | grep -q \
"</span> <a.* href=\"//localhost:6789/--original/home/Example Folder/Sample Folder/File One.md\">↓</a>"

  printf "%s\\n" "${output}" | grep -q \
"<span class=\"muted\">·</span> <span class=\"muted\">editing</span> <span class=\"muted\">·</span> <a href=\"//local"

  printf "%s\\n" "${output}" | grep -q \
"host:6789/home:1/1/1?--limit=.*&--columns=.*&--delete\">-</a> <span class=\"muted\">\|</span> <a "

  printf "%s\\n" "${output}" | grep -q \
"href=\"//localhost:6789/home:1/1/?--limit=.*&--columns=.*&--add\">+</a></strong></nav>"
}

# header crumbs ###############################################################

@test "'browse <notebook>:<folder-id>/<folder-id>/<file-id>' with local notebook displays header crumbs with id with file." {
  {
    "${_NB}" init

    mkdir -p "${_TMP_DIR}/Local Notebook"
    cd "${_TMP_DIR}/Local Notebook"

    "${_NB}" notebooks init <<< "y${_NEWLINE}"

    "${_NB}" add  "Example Folder/Sample Folder/File One.md"  \
      --title     "Example Title"                             \
      --content   "Example content."

    declare _local_notebook_param="--local=${_TMP_DIR//$'/'/%2F}%2FLocal%20Notebook"
    declare _expected_params="?${_local_notebook_param}&--limit=.*&--columns=.*"
  }

  run "${_NB}" browse local:1/1/1 --header

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    == 0 ]]

  printf "%s\\n" "${output}" | grep -q \
"<nav class=\"header-crumbs\"><strong><a href=\"//localhost:6789/${_expected_params}\"><span class=\"muted\">❯</span>nb</a> <span class=\"muted\">·</span> "

  printf "%s\\n" "${output}" | grep -q \
" <span class=\"muted\">·</span> <a href=\"//localhost:6789/local:${_expected_params}\">local</a> <span class=\"muted\">:</span> "

  printf "%s\\n" "${output}" | grep -q \
" <span class=\"muted\">:</span> <a href=\"//localhost:6789/local:1/${_expected_params}\">Example Folder</a> <span class=\"muted\">/</span> "

  printf "%s\\n" "${output}" | grep -q \
" <span class=\"muted\">/</span> <a href=\"//localhost:6789/local:1/1/${_expected_params}\">Sample Folder</a> <span class=\"muted\">/</span> "

  printf "%s\\n" "${output}" | grep -q \
" <span class=\"muted\">/</span> <span class=\"muted\">1</span> "

  printf "%s\\n" "${output}" | grep -q \
"1</span> <span class=\"muted\">·</span> <a"

  printf "%s\\n" "${output}" | grep -q \
"</span> <a.* href=\"//localhost:6789/--original/local/Example Folder/Sample Folder/File One.md?${_local_notebook_param}\">↓</a>"

  printf "%s\\n" "${output}" | grep -q \
"<a href=\"//localhost:6789/local:1/1/1${_expected_params}&--edit\">edit</a> <span class=\"muted\">\|</span> <a "

  printf "%s\\n" "${output}" | grep -q \
"href=\"//localhost:6789/local:1/1/${_expected_params}&--add\">+</a></strong></nav>"
}

@test "'browse <notebook>:<file-id>' displays header crumbs with id with file." {
  {
    "${_NB}" init

    "${_NB}" add  "File One.md"       \
      --title     "Example Title"     \
      --content   "Example content."
  }

  run "${_NB}" browse home:1 --header

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    == 0 ]]

  printf "%s\\n" "${output}" | grep -q \
"<nav class=\"header-crumbs\"><strong><a href=\"//localhost:6789/?--limit=.*&--columns=.*\"><span class=\"muted\">❯</span>nb</a> <span class=\"muted\">·</span>"

  printf "%s\\n" "${output}" | grep -q \
" <span class=\"muted\">·</span> <a href=\"//localhost:6789/home:?--limit=.*&--columns=.*\">home</a> <span class=\"muted\">:</span"

  printf "%s\\n" "${output}" | grep -q \
" <span class=\"muted\">:</span> <span class=\"muted\">1</span> "

  printf "%s\\n" "${output}" | grep -q \
"1</span> <span class=\"muted\">·</span> "

  printf "%s\\n" "${output}" | grep -q \
"</span> <a.* href=\"//localhost:6789/--original/home/File One.md\">↓</a>"

  printf "%s\\n" "${output}" | grep -q \
" <a href=\"//localhost:6789/home:1?--limit=.*&--columns=.*&--edit\">edit</a> <span class=\"muted\">\|</span> <a "

  printf "%s\\n" "${output}" | grep -q \
"href=\"//localhost:6789/home:?--limit=.*&--columns=.*&--add\">+</a></strong></nav>"
}

@test "'browse <notebook>:<folder-id>/<folder-id>/<file-id>' displays header crumbs with id with file." {
  {
    "${_NB}" init

    "${_NB}" add  "Example Folder/Sample Folder/File One.md"  \
      --title     "Example Title"                             \
      --content   "Example content."
  }

  run "${_NB}" browse home:1/1/1 --header

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    == 0 ]]

  printf "%s\\n" "${output}" | grep -q \
"<nav class=\"header-crumbs\"><strong><a href=\"//localhost:6789/?--limit=.*&--columns=.*\"><span class=\"muted\">❯</span>nb</a> <span class=\"muted\">·</span> "

  printf "%s\\n" "${output}" | grep -q \
" <span class=\"muted\">·</span> <a href=\"//localhost:6789/home:?--limit=.*&--columns=.*\">home</a> <span class=\"muted\">:</span> "

  printf "%s\\n" "${output}" | grep -q \
" <span class=\"muted\">:</span> <a href=\"//localhost:6789/home:1/?--limit=.*&--columns=.*\">Example Folder</a> <span class=\"muted\">/</span> "

  printf "%s\\n" "${output}" | grep -q \
" <span class=\"muted\">/</span> <a href=\"//localhost:6789/home:1/1/?--limit=.*&--columns=.*\">Sample Folder</a> <span class=\"muted\">/</span> "

  printf "%s\\n" "${output}" | grep -q \
" <span class=\"muted\">/</span> <span class=\"muted\">1</span> "

  printf "%s\\n" "${output}" | grep -q \
"1</span> <span class=\"muted\">·</span> <a"

  printf "%s\\n" "${output}" | grep     -q \
"</span> <a.* href=\"//localhost:6789/--original/home/Example Folder/Sample Folder/File One.md\">↓</a>"

  printf "%s\\n" "${output}" | grep -q \
"<a href=\"//localhost:6789/home:1/1/1?--limit=.*&--columns=.*&--edit\">edit</a> <span class=\"muted\">\|</span> <a "

  printf "%s\\n" "${output}" | grep -q \
"href=\"//localhost:6789/home:1/1/?--limit=.*&--columns=.*&--add\">+</a></strong></nav>"
}

@test "'browse <notebook>:<folder-id>/<file-id>' displays header crumbs with folder." {
  {
    "${_NB}" init

    "${_NB}" add  "Example Folder/File One.md"  \
      --title     "Example Title"               \
      --content   "Example content."
  }

  run "${_NB}" browse home:1/1 --header

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    == 0 ]]


  printf "%s\\n" "${output}" | grep -q \
"<nav class=\"header-crumbs\"><strong><a href=\"//localhost:6789/?--limit=.*&--columns=.*\"><span class=\"muted\">❯</span>nb</a> <span class=\"muted\">·</span> "

  printf "%s\\n" "${output}" | grep -q \
" <span class=\"muted\">·</span> <a href=\"//localhost:6789/home:?--limit=.*&--columns=.*\">home</a> <span class=\"muted\">:</span> "

  printf "%s\\n" "${output}" | grep -q \
" <span class=\"muted\">:</span> <a href=\"//localhost:6789/home:1/?--limit=.*&--columns=.*\">Example Folder</a> <span class=\"muted\">/</span> "

  printf "%s\\n" "${output}" | grep -q \
" <span class=\"muted\">/</span> <span class=\"muted\">1</span> "

  printf "%s\\n" "${output}" | grep -q \
"1</span> <span class=\"muted\">·</span> <a"

  printf "%s\\n" "${output}" | grep -q \
"</span> <a.* href=\"//localhost:6789/--original/home/Example Folder/File One.md\">↓</a>"

  printf "%s\\n" "${output}" | grep -q \
"<a href=\"//localhost:6789/home:1/1?--limit=.*&--columns=.*&--edit\">edit</a> <span class=\"muted\">|</span> <a "

  printf "%s\\n" "${output}" | grep -q \
"href=\"//localhost:6789/home:1/?--limit=.*&--columns=.*&--add\">+</a></strong></nav>"
}

@test "'browse <notebook>:<folder-id>/<folder-id>' displays header crumbs with folder." {
  {
    "${_NB}" init

    "${_NB}" add  "Example Folder/Sample Folder/File One.md"  \
      --title     "Example Title"                             \
      --content   "Example content."

    "${_NB}" notebooks add "Example Notebook"
    "${_NB}" use "Example Notebook"
  }

  run "${_NB}" browse home:1/1/ --header

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    == 0 ]]

  printf "%s\\n" "${output}" | grep -q \
"<nav class=\"header-crumbs\"><strong><a href=\"//localhost:6789/?--limit=.*&--columns=.*\"><span class=\"muted\">❯</span>nb</a> <span class=\"muted\">·</span> "

  printf "%s\\n" "${output}" | grep -q \
" <span class=\"muted\">·</span> <a href=\"//localhost:6789/home:?--limit=.*&--columns=.*\">home</a> <span class=\"muted\">:</span> "

  printf "%s\\n" "${output}" | grep -q \
" <span class=\"muted\">:</span> <a href=\"//localhost:6789/home:1/?--limit=.*&--columns=.*\">Example Folder</a> <span class=\"muted\">/</span> "

  printf "%s\\n" "${output}" | grep -q \
" <span class=\"muted\">/</span> <a href=\"//localhost:6789/home:1/1/?--limit=.*&--columns=.*\">Sample Folder</a> <span class=\"muted\">/</span> <a "

  printf "%s\\n" "${output}" | grep -q \
"href=\"//localhost:6789/home:1/1/?--limit=.*&--columns=.*&--add\">+</a></strong></nav>"

  printf "%s\\n" "${output}" | grep -q -v "↓"


  run "${_NB}" browse home:1/1/ --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    == 0  ]]

  printf "%s\\n" "${output}" | grep -q \
"<nav class=\"header-crumbs\"><strong>"
}

@test "'browse <notebook-path>/<folder>/<filename>' displays header crumbs with folder and id for file." {
  {
    "${_NB}" init

    "${_NB}" add  "Example Folder/File One.md"  \
      --title     "Example Title"               \
      --content   "Example content."
  }

  run "${_NB}" browse "${NB_DIR}/home/Example Folder/File One.md" --header

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    == 0  ]]

  printf "%s\\n" "${output}" | grep -q \
"<nav class=\"header-crumbs\"><strong><a href=\"//localhost:6789/?--limit.*\"><span class=\"muted\">❯</span>nb</a> <span class=\"muted\">·</span> "

  printf "%s\\n" "${output}" | grep -q \
" <span class=\"muted\">·</span> <a href=\"//localhost:6789/home:?--limit=.*&--columns=.*\">home</a> <span class=\"muted\">:</span> "

  printf "%s\\n" "${output}" | grep -q \
" <span class=\"muted\">:</span> <a href=\"//localhost:6789/home:1/?--limit=.*&--columns=.*\">Example Folder</a> <span class=\"muted\">/</span> "

  printf "%s\\n" "${output}" | grep -q \
" <span class=\"muted\">/</span> <span class=\"muted\">1</span> "

  printf "%s\\n" "${output}" | grep -q \
"1</span> <span class=\"muted\">·</span> <a"

  printf "%s\\n" "${output}" | grep -q \
"</span> <a.* href=\"//localhost:6789/--original/home/Example Folder/File One.md\">↓</a>"

  printf "%s\\n" "${output}" | grep -q \
"<a href=\"//localhost:6789/home:1/1?--limit=.*&--columns=.*&--edit\">edit</a> <span class=\"muted\">\|</span> <a "

  printf "%s\\n" "${output}" | grep -q \
"href=\"//localhost:6789/home:1/?--limit=.*&--columns=.*&--add\">+</a></strong></nav>"
}

@test "'browse <notebook-path>/<folder>' displays header crumbs with folder." {
  {
    "${_NB}" init

    "${_NB}" add  "Example Folder/File One.md"  \
      --title     "Example Title"               \
      --content   "Example content."
  }

  run "${_NB}" browse "${NB_DIR}/home/Example Folder" --header

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    == 0 ]]

  printf "%s\\n" "${output}" | grep -q \
"<nav class=\"header-crumbs\"><strong><a href=\"//localhost:6789/?--limit=.*&--columns=.*\"><span class=\"muted\">❯</span>nb</a> <span class=\"muted\">·</span> "

  printf "%s\\n" "${output}" | grep -q \
" <span class=\"muted\">·</span> <a href=\"//localhost:6789/home:?--limit=.*&--columns=.*\">home</a> <span class=\"muted\">:</span> "

  printf "%s\\n" "${output}" | grep -q \
" <span class=\"muted\">:</span> <a href=\"//localhost:6789/home:1/?--limit=.*&--columns=.*\">Example Folder</a> <span class=\"muted\">/</span> <a "

  printf "%s\\n" "${output}" | grep -q \
"href=\"//localhost:6789/home:1/?--limit=.*&--columns=.*&--add\">+</a></strong></nav>"

  printf "%s\\n" "${output}" | grep -q -v "↓"
}
