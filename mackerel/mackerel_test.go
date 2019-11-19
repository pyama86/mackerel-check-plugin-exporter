package mackerel

import (
	"context"
	"testing"
	"time"

	"github.com/mackerelio/mackerel-agent/config"

	"github.com/mackerelio/golib/logging"
	"github.com/mackerelio/mackerel-agent/checks"
)

func TestLoop(t *testing.T) {
	if testing.Verbose() {
		logging.SetLogLevel(logging.DEBUG)
	}

	ctx, cancel := context.WithCancel(context.Background())
	exitCh := make(chan error)

	checkers := []*checks.Checker{
		&checks.Checker{
			Name: "example1",
			Config: &config.CheckPlugin{
				Command: config.Command{
					Args: []string{"echo", "0"},
				},
			},
		},
	}

	// Start looping!
	go func() {
		exitCh <- Loop(checkers, ctx)
	}()

	timer := time.NewTimer(time.Second * 1)
	<-timer.C

	v, _ := CheckResult.Load("example1")
	if v.(checks.Status) != "OK" {
		t.Errorf("can't get status got: %s", v)
	}

	cancel()
	exitErr := <-exitCh
	if exitErr != nil {
		t.Errorf("exitErr should be nil, got: %s", exitErr)
	}
}
