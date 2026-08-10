# M365 Cleanup Manager

M365 Cleanup Manager is an open-source PowerShell-based Microsoft 365 administration tool for controlled data cleanup.

The project is designed for Microsoft 365 administrators and compliance teams who need to discover, review, delete, and verify Microsoft 365 data in a controlled and auditable way.

## Project Status

🚧 **Early Development**

The project is currently in the foundation and discovery stage.

Destructive operations are disabled during the initial development phase.

---

# Scope

The initial release is intentionally limited to the following capabilities.

## 1. Former Employee Cleanup

Discover and manage data associated with former employees, including:

- Exchange mailbox data
- Inactive mailboxes
- OneDrive data
- Selected SharePoint data
- Retention and hold status
- Deletion eligibility
- Deletion preview
- Controlled deletion
- Deletion verification
- Audit logging

## 2. Targeted Cleanup

Allow administrators or compliance users to locate and manage specific:

- Emails
- OneDrive files
- SharePoint files

The workflow is:

Search → Identify → Review → Preview → Delete → Verify → Audit

## 3. GDPR / Deleted User Cleanup

Support data discovery when the original Microsoft 365 user object is no longer available.

The tool will be able to investigate:

- Deleted users
- Users no longer present in Active or Deleted Users
- Inactive mailboxes
- Orphaned OneDrive sites
- Remaining emails in other mailboxes
- SharePoint data

The tool will distinguish between:

- Confirmed matches
- Potential matches
- Protected data
- Data that cannot be found

## 4. Bulk Processing

Support controlled bulk operations through CSV input.

The application will provide:

- Ready
- Blocked
- Review Required
- Completed
- Failed

states.

## 5. Compliance and Safety

The application follows:

Discovery → Review → Approval → Deletion → Verification → Audit

Destructive operations must never occur automatically simply because data was discovered.

The application will check applicable retention, eDiscovery, legal hold, and other Microsoft 365 protection mechanisms before attempting deletion.

## 6. Graphical Interface

The application will use a Windows Presentation Foundation (WPF) interface.

Planned sections:

- Dashboard
- Employees
- Targeted Cleanup
- GDPR / Deleted User Cleanup
- Discovery
- Review
- Deletion
- Audit History
- Settings

---

# Architecture

The application is being designed with a separation between discovery and deletion.

```text
                         WPF GUI
                            │
                            ▼
                    Application Layer
                            │
              ┌─────────────┴─────────────┐
              │                           │
        Discovery Engine            Deletion Engine
              │                           │
       ┌──────┼──────┐             ┌──────┼──────┐
       │      │      │             │      │      │
    Graph  Exchange  SPO         Graph  Exchange  SPO
       │      │      │             │      │      │
       └──────┼──────┘             └──────┼──────┘
              │                           │
              └─────────────┬─────────────┘
                            ▼
                     Audit / Reports