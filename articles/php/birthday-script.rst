Showing birthdays using php
###########################
:date: 2009-12-30 11:27
:author: Jan
:tags: MySQL, php, scouts, script, birthdays
:slug: birthday-script 

For our local scouting group it seemed nice to write a birthday script which displays for every member on the day of his/her birthday the name and age on our homepage.

Something like "We wish XXX a happy # anniversary!'

To accomplish this I wrote a php script which gets the data of our members from a mysql db and shows the messages on the right day on our website. In the meantime also an automatic mail will be send to the person with some sort of 'personal' message. 

database connection (db_connectPear.php)

.. code:: php

    < ?php
    $dsn = array(
     'phptype' => 'mysql',
     'username' => 'DBUSERNAME',
     'password' => 'DBPASSWORD',
     'hostspec' => 'localhost',
     'database' => $database,
    );
    $db_object = DB::connect($dsn, TRUE);
    if(DB::isError($db_object)) {
     die($db_object->getMessage());
    }
    $db_object->setFetchMode(DB_FETCHMODE_ASSOC);
    ?>

birthday script (birthday.php)

.. code:: php

    < ?php
    $database = 'DBNAME';
    require 'db_connectPear.php';
    $selectLeden = 'SELECT *, round((to_days(now())-to_days(Geboortedatum))/365) as leeftijd
    FROM `ledenlijst` WHERE '
    . ' DAYOFMONTH(Geboortedatum)=date_format(now(),\'%d\') AND '
    . ' MONTH(Geboortedatum)=date_format(now(),\'%c\') ORDER BY voornaam ASC';
    $queryLeden = mysql_query($selectLeden)or die(mysql_error());

    $selectStam = 'SELECT *, round((to_days(now())-to_days(Geboortedatum))/365) as leeftijd
    FROM `stam` WHERE '
    . ' DAYOFMONTH(Geboortedatum)=date_format(now(),\'%d\') AND '
    . ' MONTH(Geboortedatum)=date_format(now(),\'%c\') ORDER BY voornaam ASC';
    $queryStam = mysql_query($selectStam)or die(mysql_error());

    if (mysql_num_rows($queryLeden) == 0) {
    if (mysql_num_rows($queryStam) == 0) {
    } else {
    
    echo "       Wij wensen";
    while($list = mysql_fetch_object($queryStam)){
    $naam = $list->voornaam." ".$list->achternaam;
    echo ("$naam, ");
    if ($list->mailVerjaardag == 'n') {
    $tekst="Beste ".$list->voornaam."\n \n Een gelukkige verjaardag, ".$list->leeftijd ." jaar is niet niks, geniet van deze mooie dag. \n \n De leiding \n ";
    $email = $list->email;
    $onderwerp="Gelukkige Verjaardag!";
    $headers = "From: Naam \r\n";
    mail($email,$onderwerp,$tekst,$headers);
    $sql = "UPDATE stam SET mailVerjaardag = 'y' WHERE id = '$list->id'";
    mysql_query($sql)or die(mysql_error());
    }
    }
    echo "een gelukkige verjaardag!";
    }
    } else {
    echo "       Wij wensen ";
    $setIntro = 1;
    while($list = mysql_fetch_object($queryLeden)){
    $naam = $list->voornaam." ".$list->achternaam;
    echo ("$naam - ($list->leeftijd jaar), ");
    if ($list->mailVerjaardag == 'n') {
    $tekst="Beste ".$list->voornaam."\n \n Een gelukkige verjaardag, ".$list->leeftijd ." jaar is niet niks, geniet van deze mooie dag. \n \n De leiding";
    $email = $list->email;
    $onderwerp="Gelukkige Verjaardag!";
    $headers = "From: Naam \r\n";
    mail($email,$onderwerp,$tekst,$headers);
    $sql = "UPDATE ledenlijst SET mailVerjaardag = 'y' WHERE ledenlijst_id = '$list->ledenlijst_id'";
    mysql_query($sql)or die(mysql_error());

    }
    }

    if (mysql_num_rows($queryStam) == 0) {
    } else {
    if ($setIntro != 1){
    echo "       Wij wensen ";
    }

    while($list = mysql_fetch_object($queryStam)){
    $naam = $list->voornaam." ".$list->achternaam;
    echo ("$naam, ");
    if ($list->mailVerjaardag == 'n') {
    $tekst="Beste ".$list->voornaam."\n \n Een gelukkige verjaardag, ".$list->leeftijd ." jaar is niet niks, geniet van deze mooie dag. \n \n De leiding";
    $email = $list->email;
    $onderwerp="Gelukkige Verjaardag!";
    $headers = "From: Naam \r\n";
    mail($email,$onderwerp,$tekst,$headers);
    $sql = "UPDATE stam SET mailVerjaardag = 'y' WHERE id = '$list->id'";
    mysql_query($sql)or die(mysql_error());
    }
    }
    }
    echo "een gelukkige verjaardag!";
    }
    ?>
