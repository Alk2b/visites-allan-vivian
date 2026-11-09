def test_reset_remet_le_compteur_a_zero(client):
    client.get("/")
    client.get("/")
    resp = client.post("/reset")
    assert resp.status_code == 200
    assert resp.json() == {"visites": 0}
    assert client.get("/").json() == {"visites": 1}


def test_reset_redis_absent(client, fake_server):
    fake_server.connected = False
    resp = client.post("/reset")
    assert resp.status_code == 503
    assert resp.text == "redis down"
