# Interpreting results

The [Connectivity object](./Connectivity%20Object.md) provides the data to help determining if a URL is block and what URL, URL pattern, DNS aliases, and IP addresses may need to be unblocked. The main properties of interest from the Connectivity object that are useful for determining if a URL or service is blocked or functional are:

* **Blocked** - whether the service appears to be blocked. Value should be **false**.
* **TestUrl** - the URL that was used to perform the test.
* **UnblockUrl** - the URL to get unblocked. Can be a URL pattern rather than a literal URL.
* **DnsAliases** - a list of DNS aliases for the TestUrl. Pattern based unblocks of the TestUrl may need matching unblocks of all the DNS aliases.
* **IpAddresses** - a list of IP addresses corresponding to the TestUrl. Unblocking based on the listed IP addresses is not effective due to cloud providers and content delivery networks that may return many different IP addresses.
* **Description** - a description of what the URL is for.
* **Resolved** - whether the URL resolves its DNS entry to IP addresses or DNS aliases. Value should be **true**.
* **ExpectedStatusCode** - the expected HTTP status code returned by the test.
* **ActualStatusCode** - the actual HTTP status code returned by the test. Value will be 0 when Blocked is true or Resolved is false.
* **UnexpectedStatus** - was the actual status code an unexpected value regardless of whether the actual status code was the same as the expected status code.

Some blocks may be the result of proxies or other devices that perform SSL/TLS interception. In some cases connections may fail because the certificates used for SSL/TLS interception are purposely not in the endpoint's certificate trust store. In other cases the certificates for SSL/TLS interception may be trusted by the endpoint since the certificates are in the endpoint's certificate trust store, but the endpoint or particular software (e.g. the browser) implements certificate pinning that results in failed connections. Properties that can help determine these cases are:

* **ServerCertificate.HasError** - whether there is a generic TLS error. Value should be **false**.
* **ServerCertificate.ErrorMessage** - the TLS error message.
* **ServerCertificate.Error** - the [System.Net.Security.SslPolicyErrors](https://docs.microsoft.com/en-us/dotnet/api/system.net.security.sslpolicyerrors) value.
* **ServerCertificate.HasValidationError** - whether there is a TLS error related to certificate validation. Value should be **false**.
* **ServerCertificate.ValidationErrorMessage** - the TLS validation error message.