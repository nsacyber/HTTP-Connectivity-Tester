# Interpreting results

The [Connectivity object](./Connectivity%20Object.md) provides the data to help determing if a URL is block and what URL, URL pattern, DNS aliases, and IP addresses may need to be unblocked. The main properties of interest from the Connectivity object that are useful for determining if a URL or service is blocked or functional are:

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