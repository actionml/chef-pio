#!/usr/bin/env bats

@test "UR integration smoke test" {
  sudo -u aml -i bash -c "nohup pio eventserver &>/dev/null &"

  # Temporary fix for examples/integration-test
  sudo -u aml -i bash -c "cd ~/ur; sed -i 's/python \(.*.py\)/python3 \1/' examples/integration-test"

  run sudo -u aml -i bash -c "cd ~/ur && ./examples/integration-test"

  [ "$status" -eq 0 ] || echo -e "$output"
  return $status 
}
