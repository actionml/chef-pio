#!/usr/bin/env bats

@test "UR integration smoke test" {
  run sudo -u aml -iE bash -c "cd ~/ur && ./examples/integration-test"

  [ "$status" -eq 0 ] || echo -e "$output"
  return $status 
}
