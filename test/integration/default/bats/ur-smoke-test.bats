#!/usr/bin/env bats

@test "UR integration smoke test" {
  sudo -u aml -i bash -c "nohup pio eventserver &>/dev/null &"

  run sudo -u aml -i bash -c "cd ~/ur && ./examples/integration-test"

  [ "$status" -eq 0 ] || echo -e "$output"
  return $status 
}
