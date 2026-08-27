# Security

AEOS CLI treats inspected repositories as untrusted input.

Core rules:
- configuration is data, never executable code;
- network access is not required for validation;
- repository-controlled commands are never automatically executed;
- file/path handling must stay within intended project boundaries;
- parser resource usage must be bounded;
- dependencies should be minimized and reviewed.
