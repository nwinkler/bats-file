#!/usr/bin/env bats

load 'test_helper'
fixtures 'exist'

# Correctness
@test 'assert_link_exist() <link>: returns 0 if <link> exists' {
  local -r file="${TEST_FIXTURE_ROOT}/dir/mylink"
  run assert_link_exist "$file"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test 'assert_link_exist() <link>: returns 0 if <link> exists and points to <file>' {
  local -r link="${TEST_FIXTURE_ROOT}/dir/mylink"
  local -r file="file"
  run assert_link_exist "$link" "$file"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test 'assert_link_exist() <link>: returns 1 if <link> exists, but does not point to <file>' {
  local -r link="${TEST_FIXTURE_ROOT}/dir/mylink"
  local -r file="file.does_not_exist"
  local -r actual_file="file"
  run assert_link_exist "$link" "$file"
  echo "${lines[@]}"
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 5 ]
  [ "${lines[0]}" == '-- link exists, but does not point to target file --' ]
  [ "${lines[1]}" == "path     : $link" ]
  [ "${lines[2]}" == "expected : $file" ]
  [ "${lines[3]}" == "actual   : $actual_file" ]
  [ "${lines[4]}" == '--' ]
}

@test 'assert_link_exist() <link>: returns 1 and displays path if <link> does not exist' {
  local -r file="${TEST_FIXTURE_ROOT}/dir/mylink.does_not_exist"
  run assert_link_exist "$file"
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- link does not exist --' ]
  [ "${lines[1]}" == "path : $file" ]
  [ "${lines[2]}" == '--' ]
}

@test 'assert_link_exist() <link>: returns 1 and displays path if <link> exists, but is a file, not a link' {
  local -r file="${TEST_FIXTURE_ROOT}/dir/file"
  run assert_link_exist "$file"
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- exists, but is not a link --' ]
  [ "${lines[1]}" == "path : $file" ]
  [ "${lines[2]}" == '--' ]
}

@test 'assert_link_exist() <link>: returns 1 and displays path if <link> exists, but is a directory, not a link' {
  local -r file="${TEST_FIXTURE_ROOT}/dir"
  run assert_link_exist "$file"
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- exists, but is not a link --' ]
  [ "${lines[1]}" == "path : $file" ]
  [ "${lines[2]}" == '--' ]
}

# Transforming path
@test 'assert_link_exist() <link>: replace prefix of displayed path' {
  local -r BATSLIB_FILE_PATH_REM="#${TEST_FIXTURE_ROOT}"
  local -r BATSLIB_FILE_PATH_ADD='..'
  run assert_link_exist "${TEST_FIXTURE_ROOT}/dir/mylink.does_not_exist"
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- link does not exist --' ]
  [ "${lines[1]}" == "path : ../dir/mylink.does_not_exist" ]
  [ "${lines[2]}" == '--' ]
}

@test 'assert_link_exist() <link>: replace suffix of displayed path' {
  local -r BATSLIB_FILE_PATH_REM='%mylink.does_not_exist'
  local -r BATSLIB_FILE_PATH_ADD='..'
  run assert_link_exist "${TEST_FIXTURE_ROOT}/dir/mylink.does_not_exist"
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- link does not exist --' ]
  [ "${lines[1]}" == "path : ${TEST_FIXTURE_ROOT}/dir/.." ]
  [ "${lines[2]}" == '--' ]
}

@test 'assert_link_exist() <link>: replace infix of displayed path' {
  local -r BATSLIB_FILE_PATH_REM='dir'
  local -r BATSLIB_FILE_PATH_ADD='..'
  run assert_link_exist "${TEST_FIXTURE_ROOT}/dir/mylink.does_not_exist"
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- link does not exist --' ]
  [ "${lines[1]}" == "path : ${TEST_FIXTURE_ROOT}/../mylink.does_not_exist" ]
  [ "${lines[2]}" == '--' ]
}
