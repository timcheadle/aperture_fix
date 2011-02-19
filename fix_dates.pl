#!/usr/bin/perl

%dates = ();
$read_date = 0;
$replace_date = 0;

while ($line = <STDIN>) {
    if (!$replace_date) {
        # Read UUID
        if ($line =~ /<key>uuid<\/key>/) {
            print $line;
            $read_date = 1;

            $line = <STDIN>;
            if ($line =~ /<string>(.+?)<\/string>/) {
                $uuid = $1;
            }
        }

        # Read album type; only read dates for album type 4
        if ($uuid and $line =~ /<key>Album Type<\/key>/) {
            print $line;

            $line = <STDIN>;
            if ($line !~ /<string>4<\/string>/) {
                $read_date = 0;
                $uuid = undef;
            }
        }
        
        # Read project date
        if ($read_date and $line =~ /<key>ProjectEarliestDateAsTimerInterval<\/key>/) {
            print $line;

            $line = <STDIN>;
            if ($line =~ /<real>(.+?)<\/real>/) {
                $dates{$uuid} = $1;
            }

            $read_date = 0;
            $uuid = undef;
        }
    }

    if (!$read_date) {
        # Find project to replace date
        if ($line =~ /<key>ProjectUuid<\/key>/) {
            print $line;
            $replace_date = 1;

            $line = <STDIN>;
            if ($line =~ /<string>(.+?)<\/string>/) {
                $replace_uuid = $1;
            }
        }

        # Replace date
        if ($replace_uuid and $line =~ /<key>ProjectEarliestDateAsTimerInterval<\/key>/) {
            print $line;

            $line = <STDIN>;

            # If replacement date exists, swallow
            # following line and instead print replacement date
            if (exists $dates{$replace_uuid}) {
                $date = $dates{$replace_uuid};
                $line =~ s/<real>.*?<\/real>/<real>$date<\/real>/;
            }

            $replace_date = 0;
            $replace_uuid = undef;
        }
    }

    print $line;
}
