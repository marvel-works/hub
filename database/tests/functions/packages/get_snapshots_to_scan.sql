-- Start transaction and plan tests
begin;
select plan(2);

-- Declare some variables
\set user1ID '00000000-0000-0000-0000-000000000001'
\set org1ID '00000000-0000-0000-0000-000000000001'
\set repo1ID '00000000-0000-0000-0000-000000000001'
\set repo2ID '00000000-0000-0000-0000-000000000002'
\set repo3ID '00000000-0000-0000-0000-000000000003'
\set package1ID '00000000-0000-0000-0000-000000000001'
\set package2ID '00000000-0000-0000-0000-000000000002'
\set package3ID '00000000-0000-0000-0000-000000000003'
\set package4ID '00000000-0000-0000-0000-000000000004'

-- No snapshots at this point
select is(
    get_snapshots_to_scan()::jsonb,
    '[]'::jsonb,
    'No snapshots to scan expected'
);

-- Seed some data
insert into "user" (user_id, alias, email) values (:'user1ID', 'user1', 'user1@email.com');
insert into organization (organization_id, name, display_name, description, home_url)
values (:'org1ID', 'org1', 'Organization 1', 'Description 1', 'https://org1.com');
insert into repository (repository_id, name, display_name, url, repository_kind_id, user_id)
values (:'repo1ID', 'repo1', 'Repo 1', 'https://repo1.com', 0, :'user1ID');
insert into repository (repository_id, name, display_name, url, repository_kind_id, organization_id)
values (:'repo2ID', 'repo2', 'Repo 2', 'https://repo2.com', 0, :'org1ID');
insert into repository (repository_id, name, display_name, url, scanner_disabled, repository_kind_id, organization_id)
values (:'repo3ID', 'repo3', 'Repo 3', 'https://repo3.com', true, 0, :'org1ID');
insert into package (
    package_id,
    name,
    latest_version,
    repository_id
) values (
    :'package1ID',
    'package1',
    '1.0.0',
    :'repo1ID'
);
insert into snapshot (
    package_id,
    version,
    containers_images,
    created_at
) values (
    :'package1ID',
    '1.0.0',
    '[{"image": "quay.io/org/pkg1:1.0.0"}]',
    '2020-06-16 11:20:38+02'
);
insert into snapshot (
    package_id,
    version,
    containers_images,
    created_at
) values (
    :'package1ID',
    '0.0.9',
    '[{"image": "quay.io/org/pkg1:0.0.9"}]',
    '2020-06-16 11:20:37+02'
);
insert into package (
    package_id,
    name,
    latest_version,
    repository_id
) values (
    :'package2ID',
    'package2',
    '1.0.0',
    :'repo2ID'
);
insert into snapshot (
    package_id,
    version,
    containers_images,
    created_at
) values (
    :'package2ID',
    '1.0.0',
    '[
        {"image": "quay.io/org/pkg2:1.0.0", "whitelisted": false},
        {"image": "quay.io/org/pkg2helper1:1.0.0", "whitelisted": true}
    ]',
    '2020-06-16 11:20:36+02'
);
insert into package (
    package_id,
    name,
    latest_version,
    repository_id
) values (
    :'package3ID',
    'package3',
    '1.0.0',
    :'repo2ID'
);
insert into snapshot (
    package_id,
    version,
    containers_images,
    security_report,
    created_at
) values (
    :'package3ID',
    '1.0.0',
    '[{"image": "quay.io/org/pkg3:1.0.0"}]',
    '{"k": "v"}',
    '2020-06-16 11:20:35+02'
);
insert into snapshot (
    package_id,
    version,
    containers_images,
    security_report,
    security_report_created_at,
    created_at
) values (
    :'package3ID',
    '0.0.9',
    '[{"image": "quay.io/org/pkg3:0.0.9"}]',
    '{"k": "v"}',
    '2010-05-29 13:55:00',
    '2020-06-16 11:20:34+02'
);
insert into package (
    package_id,
    name,
    latest_version,
    repository_id
) values (
    :'package4ID',
    'package4',
    '1.0.0',
    :'repo3ID'
);
insert into snapshot (
    package_id,
    version,
    containers_images,
    created_at
) values (
    :'package4ID',
    '1.0.0',
    '[{"image": "quay.io/org/pkg4:1.0.0"}]',
    '2020-06-16 11:20:33+02'
);

-- Run some tests
select is(
    get_snapshots_to_scan()::jsonb,
    '[
        {
            "package_id": "00000000-0000-0000-0000-000000000001",
            "version": "1.0.0",
            "containers_images": [
                {
                    "image": "quay.io/org/pkg1:1.0.0"
                }
            ]
        },
        {
            "package_id": "00000000-0000-0000-0000-000000000001",
            "version": "0.0.9",
            "containers_images": [
                {
                    "image": "quay.io/org/pkg1:0.0.9"
                }
            ]
        },
        {
            "package_id": "00000000-0000-0000-0000-000000000002",
            "version": "1.0.0",
            "containers_images": [
                {
                    "image": "quay.io/org/pkg2:1.0.0",
                    "whitelisted": false
                }
            ]
        },
        {
            "package_id": "00000000-0000-0000-0000-000000000003",
            "version": "0.0.9",
            "containers_images": [
                {
                    "image": "quay.io/org/pkg3:0.0.9"
                }
            ]
        }
    ]'::jsonb,
    'Some snapshots to scan were expected'
);

-- Finish tests and rollback transaction
select * from finish();
rollback;
