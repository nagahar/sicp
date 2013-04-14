;; Evaは超循環評価器にmapの定義を読み込ませてから実行したため、動作した
;; 一方で、Louisはmapを基本手続きとして(primitive-proceduresに追加して)実行したが、超循環評価器の中でmapの第2引数が基本手続きとしてprimitiveタグが付与されてしまうため、applyは該当する引数を解釈できず、動作しなかった

(load "../metacircular.scm")
(driver-loop)
