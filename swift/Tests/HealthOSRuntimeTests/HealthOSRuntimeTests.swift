import Testing
import HealthOSCore
import HealthOSGOS
import HealthOSAACI
import HealthOSProviders
import HealthOSMSR
import HealthOSAsyncRuntime
import HealthOSUserAgentRuntime
import HealthOSServiceRuntime
import HealthOSSessionRuntime

// SCAFFOLD: Tier 2 runtime integration tests.
// Covers GOS, AACI, MSR, AsyncRuntime, UserAgentRuntime, ServiceRuntime, SessionRuntime.
@Suite("HealthOSRuntime")
struct HealthOSRuntimeTests {}
