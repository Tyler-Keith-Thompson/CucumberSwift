#!/usr/bin/env bash

# Apache License Version 2.0, January 2004
# https://github.com/codecov/codecov-bash/blob/master/LICENSE

set -e +o pipefail

VERSION="1.0.3"

codecov_flags=( )
url="https://codecov.io"
env="$CODECOV_ENV"
service=""
token=""
search_in=""
# shellcheck disable=SC2153
flags="$CODECOV_FLAGS"
exit_with=0
curlargs=""
curlawsargs=""
dump="0"
clean="0"
curl_s="-s"
name="$CODECOV_NAME"
include_cov=""
exclude_cov=""
ddp="$HOME/Library/Developer/Xcode/DerivedData"
xp=""
files=""
save_to=""
direct_file_upload=""
cacert="$CODECOV_CA_BUNDLE"
gcov_ignore="-not -path './bower_components/**' -not -path './node_modules/**' -not -path './vendor/**'"
gcov_include=""

ft_gcov="1"
ft_coveragepy="1"
ft_fix="1"
ft_search="1"
ft_s3="1"
ft_network="1"
ft_xcodellvm="1"
ft_xcodeplist="0"
ft_gcovout="1"
ft_html="0"
ft_yaml="0"
  gzip -nf9 "$upload_file"
  say "        $(du -h "$upload_file.gz")"

  query=$(echo "${query}" | tr -d ' ')
  say "${e}==>${x} Uploading reports"
  say "    ${e}url:${x} $url"
  say "    ${e}query:${x} $query"

  # Full query without token (to display on terminal output)
  queryNoToken=$(echo "package=$package-$VERSION&token=secret&$query" | tr -d ' ')
  # now add token to query
  query=$(echo "package=$package-$VERSION&token=$token&$query" | tr -d ' ')

  if [ "$ft_s3" = "1" ];
  then
    say "${e}->${x}  Pinging Codecov"
    say "$url/upload/v4?$queryNoToken"
    # shellcheck disable=SC2086,2090
    res=$(curl $curl_s -X POST $cacert \
          --retry 5 --retry-delay 2 --connect-timeout 2 \
          -H 'X-Reduced-Redundancy: false' \
          -H 'X-Content-Type: application/x-gzip' \
          -H 'Content-Length: 0' \
          --write-out "\n%{response_code}\n" \
          $curlargs \
          "$url/upload/v4?$query" || true)
    # a good reply is "https://codecov.io" + "\n" + "https://storage.googleapis.com/codecov/..."
    s3target=$(echo "$res" | sed -n 2p)
    status=$(tail -n1 <<< "$res")

    if [ "$status" = "200" ] && [ "$s3target" != "" ];
    then
      say "${e}->${x}  Uploading to"
      say "${s3target}"

      # shellcheck disable=SC2086
      s3=$(curl -fiX PUT \
          --data-binary @"$upload_file.gz" \
          -H 'Content-Type: application/x-gzip' \
          -H 'Content-Encoding: gzip' \
          $curlawsargs \
          "$s3target" || true)

      if [ "$s3" != "" ];
      then
        say "    ${g}->${x} Reports have been successfully queued for processing at ${b}$(echo "$res" | sed -n 1p)${x}"
        exit 0
      else
        say "    ${r}X>${x} Failed to upload"
      fi
    elif [ "$status" = "400" ];
    then
        # 400 Error
        say "${r}${res}${x}"
        exit ${exit_with}
    else
        say "${r}${res}${x}"
    fi
  fi

  say "${e}==>${x} Uploading to Codecov"

  # shellcheck disable=SC2086,2090
  res=$(curl -X POST $cacert \
        --data-binary @"$upload_file.gz" \
        --retry 5 --retry-delay 2 --connect-timeout 2 \
        -H 'Content-Type: text/plain' \
        -H 'Content-Encoding: gzip' \
        -H 'X-Content-Encoding: gzip' \
        -H 'Accept: text/plain' \
        $curlargs \
        "$url/upload/v2?$query&attempt=$i" || echo 'HTTP 500')
  # {"message": "Coverage reports upload successfully", "uploaded": true, "queued": true, "id": "...", "url": "https://codecov.io/..."\}
  uploaded=$(grep -o '\"uploaded\": [a-z]*' <<< "$res" | head -1 | cut -d' ' -f2)
  if [ "$uploaded" = "true" ]
  then
    say "    Reports have been successfully queued for processing at ${b}$(echo "$res" | head -2 | tail -1)${x}"
    exit 0
  else
    say "    ${g}${res}${x}"
    exit ${exit_with}
  fi

  say "    ${r}X> Failed to upload coverage reports${x}"
fi

exit ${exit_with}