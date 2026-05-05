"""Tests for staff management endpoints."""


STAFF_PAYLOAD = {
    "id": "staff-1",
    "first_name": "Alice",
    "last_name": "Ngono",
    "date_of_birth": "1990-04-12",
    "gender": "FEMALE",
    "nationality": "Cameroonian",
    "user_account_id": "1",
    "position": "NURSE",
    "department": "Admissions",
}


def test_admin_can_create_and_list_staff_member(client, admin_token):
    """ADMIN can create and list staff members."""
    create_response = client.post(
        "/api/v1/staff/",
        json=STAFF_PAYLOAD,
        headers={"Authorization": f"Bearer {admin_token}"},
    )
    assert create_response.status_code == 201
    assert create_response.json()["id"] == "staff-1"

    list_response = client.get(
        "/api/v1/staff/",
        headers={"Authorization": f"Bearer {admin_token}"},
    )
    assert list_response.status_code == 200
    assert list_response.json()[0]["position"] == "NURSE"


def test_operator_cannot_create_staff_member(client, operator_token):
    """OPERATOR does not have staff management permission."""
    response = client.post(
        "/api/v1/staff/",
        json=STAFF_PAYLOAD,
        headers={"Authorization": f"Bearer {operator_token}"},
    )
    assert response.status_code == 403
