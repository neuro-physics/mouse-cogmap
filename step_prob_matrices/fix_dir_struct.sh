ntrials=18
folders="cumul_prob cumul_step independent"

for folder in $folders; do
    if [ ! -d $folder ]; then
        echo Creating dir ...  $folder
        mkdir $folder
    fi
    $subdir = "$folder/ntrials_$ntrials" # $folder/ntrials_16"
    for s in $subdir; do
        if [ ! -d $s ]; then
            echo Creating dir ...  $s
            mkdir $s
        fi
        $subsubdir = "$s/stopfood" #"$s/continuefood 
        for ss in $subsubdir; do
            if [ ! -d $ss ]; then
                echo Creating dir ...  $ss
                mkdir $ss
            fi
            $subsubsubdir = "$ss/Pinit025" # "$ss/Pinit0
            for sss in $subsubsubdir; do
                if [ ! -d $sss ]; then
                    echo Creating dir ...  $sss
                    mkdir $sss
                fi
            done
        done
    done
done

mv "*ntrials_$ntrials*Pinit_0.25*cprob*stopfood*.mat" "cumul_prob/ntrials_$ntrials/stopfood/Pinit025"
mv "*ntrials_$ntrials*Pinit_0.25*cstep*stopfood*.mat" "cumul_step/ntrials_$ntrials/stopfood/Pinit025"
mv "*ntrials_$ntrials*Pinit_0.25*indept*stopfood*.mat" "independent/ntrials_$ntrials/stopfood/Pinit025"