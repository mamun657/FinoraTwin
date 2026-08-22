SELECT id, email, full_name, created_at FROM users WHERE email = 'verify_76049500@verify.local';
SELECT id, "OwnerId", name, created_at FROM businesses WHERE "OwnerId" IN (SELECT id FROM users WHERE email = 'verify_76049500@verify.local');
