; RUN: opt < %s -simplifycfg -S | FileCheck %s

; int foo1_with_default(int a) {
;   switch(a) {
;     case 10:
;       return 10;
;     case 20:
;       return 2;
;   }
;   return 4;
; }

define i32 @foo1_with_default(i32 %a) {
; CHECK-LABEL: @foo1_with_default
; CHECK: %switch.selectcmp = icmp eq i32 %a, 20
; CHECK-NEXT: %switch.select = select i1 %switch.selectcmp, i32 2, i32 4
; CHECK-NEXT: %switch.selectcmp1 = icmp eq i32 %a, 10
; CHECK-NEXT: %switch.select2 = select i1 %switch.selectcmp1, i32 10, i32 %switch.select
entry:
  switch i32 %a, label %sw.epilog [
    i32 10, label %sw.bb
    i32 20, label %sw.bb1
  ]

sw.bb:
  br label %return

sw.bb1:
  br label %return

sw.epilog:
  br label %return

return:
  %retval.0 = phi i32 [ 4, %sw.epilog ], [ 2, %sw.bb1 ], [ 10, %sw.bb ]
  ret i32 %retval.0
}
