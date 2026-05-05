"""Tests for audit history endpoints."""

from tests.test_patient import PATIENT_PAYLOAD


def test_admin_can_read_patient_audit_history(client, admin_token, operator_token):
    """Patient registration writes an audit entry that ADMIN can read."""
    register_response = client.post(
        "/api/v1/patients/",
        json=PATIENT_PAYLOAD,
        headers={"Authorization": f"Bearer {operator_token}"},
    )
    assert register_response.status_code == 201
    uhid = register_response.json()["patient"]["uhid"]

    audit_response = client.get(
        f"/api/v1/audit/patients/{uhid}",
        headers={"Authorization": f"Bearer {admin_token}"},
    )
    assert audit_response.status_code == 200
    actions = {entry["action"] for entry in audit_response.json()}
    assert "REGISTERED_PATIENT" in actions
