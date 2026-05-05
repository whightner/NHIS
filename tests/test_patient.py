"""
tests/test_patient.py
----------------------
Automated tests for patient management endpoints.

Covers:
  - Patient registration
  - Duplicate detection
  - Search and retrieval by UHID
  - Approval and rejection workflow
  - Status-based listing
  - Verification endpoints
  - Security code validation
  - Role-based access enforcement
"""

import pytest

PATIENT_PAYLOAD = {
    "first_name": "Jean",
    "last_name": "Dupont",
    "date_of_birth": "1985-06-15",
    "gender": "MALE",
    "nationality": "Cameroonian",
    "phone_number": "+237600000001",
    "national_id": "NID-12345",
}


def _register(client, token, payload=None):
    """Helper: register a patient and return the response."""
    return client.post(
        "/api/v1/patients/",
        json=payload or PATIENT_PAYLOAD,
        headers={"Authorization": f"Bearer {token}"},
    )


class TestRegistration:

    def test_operator_can_register(self, client, operator_token):
        """OPERATOR can register a new patient."""
        resp = _register(client, operator_token)
        assert resp.status_code == 201
        data = resp.json()
        assert "patient" in data
        assert data["patient"]["first_name"] == "Jean"
        assert data["patient"]["verification_status"] == "PENDING"
        assert "uhid" in data["patient"]
        assert "possible_duplicates" in data

    def test_admin_can_register(self, client, admin_token):
        """ADMIN can also register patients."""
        resp = _register(client, admin_token)
        assert resp.status_code == 201

    def test_verifier_cannot_register(self, client, db_session):
        """VERIFIER role should not be able to register patients (403)."""
        from app.core.constants import Roles, UserStatus
        from app.core.security import hash_password
        from app.modules.identity.infrastructure.models import User

        verifier = User(
            username="testverifier",
            password_hash=hash_password("Pass@123"),
            role=Roles.VERIFIER,
            status=UserStatus.ACTIVE,
            first_login=False,
        )
        db_session.add(verifier)
        db_session.commit()

        login_resp = client.post(
            "/api/v1/auth/login",
            data={"username": "testverifier", "password": "Pass@123"},
        )
        token = login_resp.json()["access_token"]

        resp = _register(client, token)
        assert resp.status_code == 403

    def test_uhid_is_unique_on_repeated_registration(self, client, operator_token):
        """Two registrations produce two distinct UHIDs."""
        r1 = _register(client, operator_token)
        r2 = _register(client, operator_token, {**PATIENT_PAYLOAD, "first_name": "Marie"})
        assert r1.status_code == 201
        assert r2.status_code == 201
        assert r1.json()["patient"]["uhid"] != r2.json()["patient"]["uhid"]


class TestDuplicateDetection:

    def test_duplicate_flagged_on_same_name_and_dob(self, client, operator_token):
        """Registering the same name + DOB returns the existing record as a duplicate."""
        _register(client, operator_token)  # First registration
        resp = _register(client, operator_token)  # Second identical registration
        assert resp.status_code == 201
        duplicates = resp.json()["possible_duplicates"]
        assert len(duplicates) >= 1

    def test_no_duplicate_for_different_dob(self, client, operator_token):
        """Different date of birth produces no duplicates."""
        _register(client, operator_token)
        resp = _register(client, operator_token, {**PATIENT_PAYLOAD, "date_of_birth": "1990-01-01"})
        assert resp.status_code == 201
        assert resp.json()["possible_duplicates"] == []


class TestSearch:

    def test_search_by_uhid(self, client, operator_token):
        """Patient can be found by exact UHID."""
        uhid = _register(client, operator_token).json()["patient"]["uhid"]
        resp = client.get(
            f"/api/v1/patients/?uhid={uhid}",
            headers={"Authorization": f"Bearer {operator_token}"},
        )
        assert resp.status_code == 200
        assert len(resp.json()) == 1
        assert resp.json()[0]["uhid"] == uhid

    def test_search_by_first_name(self, client, operator_token):
        """Partial first-name search returns matching patients."""
        _register(client, operator_token)
        resp = client.get(
            "/api/v1/patients/?first_name=Jea",
            headers={"Authorization": f"Bearer {operator_token}"},
        )
        assert resp.status_code == 200
        assert len(resp.json()) >= 1

    def test_get_by_uhid_not_found(self, client, operator_token):
        """Requesting a non-existent UHID returns 404."""
        resp = client.get(
            "/api/v1/patients/CMR-2099-XXXXXXXX",
            headers={"Authorization": f"Bearer {operator_token}"},
        )
        assert resp.status_code == 404


class TestVerificationWorkflow:

    @pytest.fixture
    def registered_uhid(self, client, operator_token):
        """Register a patient and return their UHID."""
        return _register(client, operator_token).json()["patient"]["uhid"]

    def test_approve_patient(self, client, admin_token, registered_uhid):
        """ADMIN can approve a PENDING patient."""
        resp = client.post(
            f"/api/v1/patients/{registered_uhid}/approve",
            headers={"Authorization": f"Bearer {admin_token}"},
        )
        assert resp.status_code == 200

    def test_reject_patient(self, client, admin_token, registered_uhid):
        """ADMIN can reject a PENDING patient with a reason."""
        resp = client.post(
            f"/api/v1/patients/{registered_uhid}/reject?reason=Incomplete+documents",
            headers={"Authorization": f"Bearer {admin_token}"},
        )
        assert resp.status_code == 200
        assert resp.json()["reason"] == "Incomplete documents"

    def test_approve_already_approved_returns_422(self, client, admin_token, registered_uhid):
        """Approving an already-approved patient returns 422."""
        client.post(
            f"/api/v1/patients/{registered_uhid}/approve",
            headers={"Authorization": f"Bearer {admin_token}"},
        )
        resp = client.post(
            f"/api/v1/patients/{registered_uhid}/approve",
            headers={"Authorization": f"Bearer {admin_token}"},
        )
        assert resp.status_code == 422

    def test_operator_cannot_approve(self, client, operator_token, registered_uhid):
        """OPERATOR cannot approve patients (403)."""
        resp = client.post(
            f"/api/v1/patients/{registered_uhid}/approve",
            headers={"Authorization": f"Bearer {operator_token}"},
        )
        assert resp.status_code == 403


class TestVerifyEndpoint:

    def test_verify_approved_patient(self, client, admin_token, operator_token):
        """Verifying an approved patient returns VALID status."""
        uhid = _register(client, operator_token).json()["patient"]["uhid"]
        client.post(
            f"/api/v1/patients/{uhid}/approve",
            headers={"Authorization": f"Bearer {admin_token}"},
        )
        resp = client.get(
            f"/api/v1/patients/verify/{uhid}",
            headers={"Authorization": f"Bearer {operator_token}"},
        )
        assert resp.status_code == 200
        assert resp.json()["status"] == "VALID"

    def test_verify_pending_patient_returns_403(self, client, operator_token):
        """Verifying a PENDING patient returns 403."""
        uhid = _register(client, operator_token).json()["patient"]["uhid"]
        resp = client.get(
            f"/api/v1/patients/verify/{uhid}",
            headers={"Authorization": f"Bearer {operator_token}"},
        )
        assert resp.status_code == 403


class TestStaticRoutes:

    def test_stats_endpoint_accessible(self, client, admin_token):
        """/stats does not resolve as a UHID (regression test for routing bug)."""
        resp = client.get(
            "/api/v1/patients/stats",
            headers={"Authorization": f"Bearer {admin_token}"},
        )
        assert resp.status_code == 200
        data = resp.json()
        assert "total" in data
        assert "pending" in data

    def test_pending_endpoint_accessible(self, client, operator_token):
        """/pending does not resolve as a UHID."""
        resp = client.get(
            "/api/v1/patients/pending",
            headers={"Authorization": f"Bearer {operator_token}"},
        )
        assert resp.status_code == 200
        assert isinstance(resp.json(), list)
