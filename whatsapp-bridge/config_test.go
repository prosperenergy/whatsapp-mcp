package main

import (
	"net/http"
	"testing"
)

func environment(values map[string]string) func(string) string {
	return func(key string) string {
		return values[key]
	}
}

func TestBridgeConfigDefaultsToLoopbackAndDisabledCapabilities(t *testing.T) {
	config, err := loadBridgeConfigFromEnvironment(environment(map[string]string{}))
	if err != nil {
		t.Fatalf("expected defaults to be valid: %v", err)
	}
	if config.bindAddress != "127.0.0.1" || config.port != 8080 {
		t.Fatalf("expected loopback default on port 8080, got %s:%d", config.bindAddress, config.port)
	}
	if config.sendingEnabled || config.mediaDownloadsEnabled {
		t.Fatal("expected outbound capabilities to default to disabled")
	}
}

func TestBridgeConfigRejectsNonLoopbackBinding(t *testing.T) {
	_, err := loadBridgeConfigFromEnvironment(environment(map[string]string{
		"WHATSAPP_BRIDGE_BIND_ADDRESS": "0.0.0.0",
	}))
	if err == nil {
		t.Fatal("expected a non-loopback binding to be rejected")
	}
}

func TestBridgeConfigRejectsInvalidPort(t *testing.T) {
	_, err := loadBridgeConfigFromEnvironment(environment(map[string]string{
		"WHATSAPP_BRIDGE_PORT": "70000",
	}))
	if err == nil {
		t.Fatal("expected an invalid port to be rejected")
	}
}

func TestBridgeConfigAllowsExplicitCapabilityGates(t *testing.T) {
	_, err := loadBridgeConfigFromEnvironment(environment(map[string]string{
		"WHATSAPP_BRIDGE_SEND_ENABLED": "true",
	}))
	if err == nil {
		t.Fatal("expected an enabled outbound capability to require an API token")
	}

	config, err := loadBridgeConfigFromEnvironment(environment(map[string]string{
		"WHATSAPP_BRIDGE_SEND_ENABLED":            "true",
		"WHATSAPP_BRIDGE_MEDIA_DOWNLOADS_ENABLED": "true",
		"WHATSAPP_BRIDGE_API_TOKEN":               "test-local-token",
	}))
	if err != nil {
		t.Fatalf("expected explicit gates to be valid: %v", err)
	}
	if !config.sendingEnabled || !config.mediaDownloadsEnabled {
		t.Fatal("expected explicit gates to enable the requested capabilities")
	}
}

func TestBridgeAuthorizationRequiresExactLocalToken(t *testing.T) {
	config := BridgeConfig{apiToken: "local-secret"}
	request, err := http.NewRequest(http.MethodPost, "/api/send", nil)
	if err != nil {
		t.Fatalf("failed to create request: %v", err)
	}
	if isAuthorizedBridgeRequest(request, config) {
		t.Fatal("request without token must not be authorized")
	}
	request.Header.Set("X-Prosper-Bridge-Token", "wrong-secret")
	if isAuthorizedBridgeRequest(request, config) {
		t.Fatal("request with wrong token must not be authorized")
	}
	request.Header.Set("X-Prosper-Bridge-Token", "local-secret")
	if !isAuthorizedBridgeRequest(request, config) {
		t.Fatal("request with exact token should be authorized")
	}
}
