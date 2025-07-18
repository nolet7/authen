#!/bin/sh

# Wait for the server to fully start
sleep 15

echo "[+] Granting admin UI access permission via Django shell..."

ak shell <<EOF
from django.contrib.auth import get_user_model
from authentik.rbac.models import Role, Permission

User = get_user_model()
try:
    admin = User.objects.get(username="admin")
except User.DoesNotExist:
    print("[-] Admin user not found.")
    exit()

# Create role and bind permission
role, _ = Role.objects.get_or_create(name="Admin UI Access")
perm = Permission.objects.get(codename="access_admin_interface")
role.permission_set.add(perm)

# Bind user to role if RoleBinding exists
try:
    from authentik.rbac.models import RoleBinding
    RoleBinding.objects.get_or_create(user=admin, role=role)
    print("[✓] Role-based access granted to 'admin' user.")
except ImportError:
    print("[✓] Permission added to role, but RoleBinding not available.")
EOF

