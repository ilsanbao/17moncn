package ip17mon

import "testing"

func TestFind(t *testing.T) {
	area := string(Find("8.8.8.8"))
	if area != "GOOGLE\tGOOGLE" {
		t.Error("ip find area error!")
	}
}