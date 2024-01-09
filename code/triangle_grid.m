function tg = triangle_grid(n, t)
    ng = ( ( n + 1 ) * ( n + 2 ) ) / 2;
    tg = zeros ( 2, ng );

    p = 0;

    for i = 0 : n
        for j = 0 : n - i
            k = n - i - j;
            p = p + 1;
            tg(1:2,p) = ( i * t(1:2,1) + j * t(1:2,2) + k * t(1:2,3) ) / n;
        end
    end
end