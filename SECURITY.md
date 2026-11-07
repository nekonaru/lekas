# Security Policy

## Supported versions

Lekas receives security fixes on the latest release. Older releases do not.

| Version | Supported |
|---------|-----------|
| 1.7.x (latest) | Yes |
| Older than 1.7.0 | No |

## Reporting a vulnerability

Do not open a public issue for security reports. Report privately through
GitHub's vulnerability reporting on
[this repository](https://github.com/nekonaru/lekas) (Security, then
"Report a vulnerability"). If private reporting is not enabled there, open
a minimal issue with the title `security: ...` and the maintainer will
move the discussion to a private advisory before it is published.

Include what you can: affected version, steps to reproduce, and the impact
you observed. If you are reporting on behalf of someone else, say so.

## What to expect

- Acknowledgement as soon as the maintainer can review it.
- A fix timeline once the report is confirmed, and credit in the release
  notes unless you ask to stay anonymous.
- Fixes ship in a new release; update to the newest version to stay safe.

## Scope and out of scope

In scope: the Android application, its AndroidManifest, its bundled
database, the backup import and export paths, and the project files in this
repository.

Out of scope: previous releases before 1.7.0, third-party software such as
Google Play and its services, issues on outdated Android versions below 7.0,
and spam or physical social engineering.

Please give the maintainer time to fix before publishing any details.
