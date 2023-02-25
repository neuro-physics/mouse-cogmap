
$ntrials = 18
$folders = @('cumul_prob', 'cumul_step', 'independent')

foreach ($folder in $folders)
{
    if (-not (Test-Path -Path $folder))
    {
        Write-Host 'Creating dir ... ' $folder
        mkdir $folder
    }
    $subdir = @("$folder\ntrials_$ntrials") #,"$folder\ntrials_16")
    foreach ($s in $subdir)
    {
        if (-not (Test-Path -Path $s))
        {
            Write-Host 'Creating dir ... ' $s
            mkdir $s
        }
        $subsubdir = @("$s\stopfood") # "$s\continuefood",
        foreach ($ss in $subsubdir)
        {
            if (-not (Test-Path -Path $ss))
            {
                Write-Host 'Creating dir ... ' $ss
                mkdir $ss
            }
            $subsubsubdir = @("$ss\Pinit025") # "$ss\Pinit0"
            foreach ($sss in $subsubsubdir)
            {
                if (-not (Test-Path -Path $sss))
                {
                    Write-Host 'Creating dir ... ' $sss
                    mkdir $sss
                }
            }
        }
    }
}

Move-Item "*ntrials_$ntrials*Pinit_0.25*cprob*stopfood*.mat" "cumul_prob\ntrials_$ntrials\stopfood\Pinit025"
Move-Item "*ntrials_$ntrials*Pinit_0.25*cstep*stopfood*.mat" "cumul_step\ntrials_$ntrials\stopfood\Pinit025"
Move-Item "*ntrials_$ntrials*Pinit_0.25*indept*stopfood*.mat" "independent\ntrials_$ntrials\stopfood\Pinit025"
