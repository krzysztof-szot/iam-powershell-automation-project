BeforeAll {
    $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
    $matrix = Get-Content (Join-Path $repoRoot 'config/access-matrix.example.json') -Raw |
        ConvertFrom-Json -AsHashtable
    $lab = Get-Content (Join-Path $repoRoot 'config/lab.example.json') -Raw |
        ConvertFrom-Json -AsHashtable
    $events = Import-Csv (Join-Path $repoRoot 'samples/hr-events.example.csv')
}

Describe 'IAM lab scaffold' {
    It 'includes an implementation, test and evidence record for every day' {
        foreach ($day in 1..8) {
            $number = '{0:00}' -f $day
            Join-Path $repoRoot "docs/day-$number.md" | Should -Exist
            Join-Path $repoRoot "tests/day-$number.md" | Should -Exist
            Join-Path $repoRoot "evidence/day-$number/README.md" | Should -Exist
        }
    }

    It 'maps every example policy entitlement in both environments' {
        foreach ($entitlement in ($matrix.departments.Values | ForEach-Object { $_ })) {
            $lab.ad.groupMap.ContainsKey($entitlement) | Should -BeTrue
            $lab.entra.groupMap.ContainsKey($entitlement) | Should -BeTrue
        }
    }

    It 'uses known departments and unique event IDs in the synthetic feed' {
        foreach ($event in ($events | Where-Object EventType -ne 'Leaver')) {
            $matrix.departments.ContainsKey($event.Department) | Should -BeTrue
        }
        @($events.EventId | Sort-Object -Unique).Count | Should -Be $events.Count
        $events.EventType -join ',' | Should -Be 'Joiner,Mover,Leaver'
    }
}
