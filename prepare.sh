#!/bin/bash

set -euC

base_dir="$(readlink -f $(dirname ${0}))"

work_dir="${base_dir}/_work"

if [ ! -d "${work_dir}" ]; then
  mkdir "${work_dir}"
fi

# --- Get and update the repository --- #
(
  cd "${work_dir}"
  for target in cl-web-2d-game; do
    if [ ! -d "${target}" ]; then
      git clone "https://github.com/eshamster/${target}.git"
    fi
    (
      cd "${target}"
      git pull --rebase
    )
  done
)

# --- Make configuration files from input file --- #
sample_name_list=($(ls "${work_dir}/cl-web-2d-game/sample/" | \
                    grep -e "ros\$" | \
                    sed -e "s/\.ros\$//"))

# - docker-compose.yml - #
dc_file="${base_dir}/docker-compose.yml"
cp "${base_dir}/docker-compose.yml.in" "${dc_file}"
base_indent="    "

# depends_on
echo "${base_indent}depends_on:" >> ${dc_file}
for sample in ${sample_name_list[@]}; do
  echo "${base_indent}  - ${sample}" >> ${dc_file}
done

# containers
for sample in ${sample_name_list[@]}; do
  cat<<EOI>>${dc_file}
  ${sample}:
    build: sample/
    volumes:
      - ./_cl:/root/work/lisp
    environment:
      - TARGET=${sample}
EOI
done

# - nginx/index.html - #
html_file="${base_dir}/nginx/index.html"

cat<<EOI | sed '/<body>/r /dev/stdin' "${html_file}.in" >| "${html_file}"
$(for sample in ${sample_name_list[@]}; do 
    cat<<EOHTML
    <div>
      <a href='./${sample}'>${sample}</a>: (<a href='https://github.com/eshamster/cl-web-2d-game/blob/master/sample/${sample}.ros'>source</a>)
    </div>
EOHTML
  done)
EOI

# - nginx/default.conf - #
nginx_file="${base_dir}/nginx/default.conf"

cat <<EOI | sed '/locations/r /dev/stdin' "${nginx_file}.in" >| "${nginx_file}"
$(for sample in ${sample_name_list[@]}; do
    cat<<EOLOC
  location /${sample}/ {
    proxy_pass http://${sample}:16896/;
  }
EOLOC
  done)
EOI

# --- build --- #
(
  cd "${base_dir}"
  docker-compose build
  echo "You can run containers by \"docker-compose up -d\" on \"${base_dir}\""
)
