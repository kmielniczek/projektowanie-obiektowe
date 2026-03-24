program exercise1;
type
    arr_50 = array[0..49] of integer;
var
    arr: arr_50;
    i: integer;

procedure generate(var arr: arr_50);
var
    i: integer;
begin
    for i := 0 to 49 do arr[i] := random(101);
end;

begin
    randomize(); { initialize random number generator }

    generate(arr);

    write('[');
    for i := 0 to 48 do write(arr[i], ', ');
    writeln(arr[49], ']');
end.
