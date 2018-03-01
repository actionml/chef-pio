#!/usr/bin/env bats

@test "PredictionIO status" {
  sudo -u aml -i bash -c "nohup pio eventserver &>/dev/null &"

  # We can't run the whole integration test (not enough memory)
  # run sudo -u aml -i bash -c "cd ~/ur && ./examples/integration-test"

  # So we just content with pio status
  run sudo -u aml -i bash -c "pio status"

  [ "$status" -eq 0 ] || echo -e "$output"
  return $status
}
