;; 通常のflatmapの方ではqueen-colsのオーダーはboardsizeがk列回呼び出されているので T=boardsize**2
;; Louisのプログラムではqueen-colsのオーダーはboardsizeそれぞれにk列回呼び出しているので X=boardsize**boardsize
;; 両者を割れば X=T*boardsize**(boardsize-2)
