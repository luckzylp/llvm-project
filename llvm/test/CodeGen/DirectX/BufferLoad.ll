; RUN: opt -S -dxil-op-lower %s | FileCheck %s

target triple = "dxil-pc-shadermodel6.6-compute"

declare void @scalar_user(float)
declare void @vector_user(<4 x float>)
declare void @check_user(i1)

define void @loadv4f32() {
  ; CHECK: [[BIND:%.*]] = call %dx.types.Handle @dx.op.createHandleFromBinding(i32 217,
  ; CHECK: [[HANDLE:%.*]] = call %dx.types.Handle @dx.op.annotateHandle(i32 216, %dx.types.Handle [[BIND]]
  %buffer = call target("dx.TypedBuffer", <4 x float>, 0, 0, 0)
      @llvm.dx.resource.handlefrombinding.tdx.TypedBuffer_v4f32_0_0_0(
          i32 0, i32 0, i32 1, i32 0, i1 false, ptr null)

  ; The temporary casts should all have been cleaned up
  ; CHECK-NOT: %dx.resource.casthandle

  ; CHECK: [[DATA0:%.*]] = call %dx.types.ResRet.f32 @dx.op.bufferLoad.f32(i32 68, %dx.types.Handle [[HANDLE]], i32 0, i32 undef) #[[#ATTR:]]
  %load0 = call {<4 x float>, i1} @llvm.dx.resource.load.typedbuffer(
      target("dx.TypedBuffer", <4 x float>, 0, 0, 0) %buffer, i32 0)
  %data0 = extractvalue {<4 x float>, i1} %load0, 0

  ; The extract order depends on the users, so don't enforce that here.
  ; CHECK-DAG: [[VAL0_0:%.*]] = extractvalue %dx.types.ResRet.f32 [[DATA0]], 0
  %data0_0 = extractelement <4 x float> %data0, i32 0
  ; CHECK-DAG: [[VAL0_2:%.*]] = extractvalue %dx.types.ResRet.f32 [[DATA0]], 2
  %data0_2 = extractelement <4 x float> %data0, i32 2

  ; If all of the uses are extracts, we skip creating a vector
  ; CHECK-NOT: insertelement
  ; CHECK-DAG: call void @scalar_user(float [[VAL0_0]])
  ; CHECK-DAG: call void @scalar_user(float [[VAL0_2]])
  call void @scalar_user(float %data0_0)
  call void @scalar_user(float %data0_2)

  ; CHECK: [[DATA4:%.*]] = call %dx.types.ResRet.f32 @dx.op.bufferLoad.f32(i32 68, %dx.types.Handle [[HANDLE]], i32 4, i32 undef) #[[#ATTR]]
  %load4 = call {<4 x float>, i1} @llvm.dx.resource.load.typedbuffer(
      target("dx.TypedBuffer", <4 x float>, 0, 0, 0) %buffer, i32 4)
  %data4 = extractvalue {<4 x float>, i1} %load4, 0

  ; CHECK: extractvalue %dx.types.ResRet.f32 [[DATA4]], 0
  ; CHECK: extractvalue %dx.types.ResRet.f32 [[DATA4]], 1
  ; CHECK: extractvalue %dx.types.ResRet.f32 [[DATA4]], 2
  ; CHECK: extractvalue %dx.types.ResRet.f32 [[DATA4]], 3
  ; CHECK: insertelement <4 x float> poison
  ; CHECK: insertelement <4 x float>
  ; CHECK: insertelement <4 x float>
  ; CHECK: insertelement <4 x float>
  call void @vector_user(<4 x float> %data4)

  ; CHECK: [[DATA12:%.*]] = call %dx.types.ResRet.f32 @dx.op.bufferLoad.f32(i32 68, %dx.types.Handle [[HANDLE]], i32 12, i32 undef) #[[#ATTR]]
  %load12 = call {<4 x float>, i1} @llvm.dx.resource.load.typedbuffer(
      target("dx.TypedBuffer", <4 x float>, 0, 0, 0) %buffer, i32 12)
  %data12 = extractvalue {<4 x float>, i1} %load12, 0

  ; CHECK: [[DATA12_3:%.*]] = extractvalue %dx.types.ResRet.f32 [[DATA12]], 3
  %data12_3 = extractelement <4 x float> %data12, i32 3

  ; If there are a mix of users we need the vector, but extracts are direct
  ; CHECK: call void @scalar_user(float [[DATA12_3]])
  call void @scalar_user(float %data12_3)
  call void @vector_user(<4 x float> %data12)

  ret void
}

define void @index_dynamic(i32 %bufindex, i32 %elemindex) {
  ; CHECK: [[BIND:%.*]] = call %dx.types.Handle @dx.op.createHandleFromBinding(i32 217,
  ; CHECK: [[HANDLE:%.*]] = call %dx.types.Handle @dx.op.annotateHandle(i32 216, %dx.types.Handle [[BIND]]
  %buffer = call target("dx.TypedBuffer", <4 x float>, 0, 0, 0)
      @llvm.dx.resource.handlefrombinding.tdx.TypedBuffer_v4f32_0_0_0(
          i32 0, i32 0, i32 1, i32 0, i1 false, ptr null)

  ; CHECK: [[LOAD:%.*]] = call %dx.types.ResRet.f32 @dx.op.bufferLoad.f32(i32 68, %dx.types.Handle [[HANDLE]], i32 %bufindex, i32 undef) #[[#ATTR]]
  %load = call {<4 x float>, i1} @llvm.dx.resource.load.typedbuffer(
      target("dx.TypedBuffer", <4 x float>, 0, 0, 0) %buffer, i32 %bufindex)
  %data = extractvalue {<4 x float>, i1} %load, 0

  ; CHECK: [[ALLOCA:%.*]] = alloca [4 x float]
  ; CHECK: [[V0:%.*]] = extractvalue %dx.types.ResRet.f32 [[LOAD]], 0
  ; CHECK: [[A0:%.*]] = getelementptr inbounds [4 x float], ptr [[ALLOCA]], i32 0, i32 0
  ; CHECK: store float [[V0]], ptr [[A0]]
  ; CHECK: [[V1:%.*]] = extractvalue %dx.types.ResRet.f32 [[LOAD]], 1
  ; CHECK: [[A1:%.*]] = getelementptr inbounds [4 x float], ptr [[ALLOCA]], i32 0, i32 1
  ; CHECK: store float [[V1]], ptr [[A1]]
  ; CHECK: [[V2:%.*]] = extractvalue %dx.types.ResRet.f32 [[LOAD]], 2
  ; CHECK: [[A2:%.*]] = getelementptr inbounds [4 x float], ptr [[ALLOCA]], i32 0, i32 2
  ; CHECK: store float [[V2]], ptr [[A2]]
  ; CHECK: [[V3:%.*]] = extractvalue %dx.types.ResRet.f32 [[LOAD]], 3
  ; CHECK: [[A3:%.*]] = getelementptr inbounds [4 x float], ptr [[ALLOCA]], i32 0, i32 3
  ; CHECK: store float [[V3]], ptr [[A3]]
  ;
  ; CHECK: [[PTR:%.*]] = getelementptr inbounds [4 x float], ptr [[ALLOCA]], i32 0, i32 %elemindex
  ; CHECK: [[X:%.*]] = load float, ptr [[PTR]]
  %x = extractelement <4 x float> %data, i32 %elemindex

  ; CHECK: call void @scalar_user(float [[X]])
  call void @scalar_user(float %x)

  ret void
}

define void @loadf32() {
  ; CHECK: [[BIND:%.*]] = call %dx.types.Handle @dx.op.createHandleFromBinding(i32 217,
  ; CHECK: [[HANDLE:%.*]] = call %dx.types.Handle @dx.op.annotateHandle(i32 216, %dx.types.Handle [[BIND]]
  %buffer = call target("dx.TypedBuffer", float, 0, 0, 0)
      @llvm.dx.resource.handlefrombinding.tdx.TypedBuffer_f32_0_0_0(
          i32 0, i32 0, i32 1, i32 0, i1 false, ptr null)

  ; CHECK: [[DATA0:%.*]] = call %dx.types.ResRet.f32 @dx.op.bufferLoad.f32(i32 68, %dx.types.Handle [[HANDLE]], i32 0, i32 undef) #[[#ATTR]]
  %load0 = call {float, i1} @llvm.dx.resource.load.typedbuffer(
      target("dx.TypedBuffer", float, 0, 0, 0) %buffer, i32 0)
  %data0 = extractvalue {float, i1} %load0, 0

  ; CHECK: [[VAL0:%.*]] = extractvalue %dx.types.ResRet.f32 [[DATA0]], 0
  ; CHECK: call void @scalar_user(float [[VAL0]])
  call void @scalar_user(float %data0)

  ret void
}

define void @loadv2f32() {
  ; CHECK: [[BIND:%.*]] = call %dx.types.Handle @dx.op.createHandleFromBinding(i32 217,
  ; CHECK: [[HANDLE:%.*]] = call %dx.types.Handle @dx.op.annotateHandle(i32 216, %dx.types.Handle [[BIND]]
  %buffer = call target("dx.TypedBuffer", <2 x float>, 0, 0, 0)
      @llvm.dx.resource.handlefrombinding.tdx.TypedBuffer_v2f32_0_0_0(
          i32 0, i32 0, i32 1, i32 0, i1 false, ptr null)

  ; CHECK: [[DATA0:%.*]] = call %dx.types.ResRet.f32 @dx.op.bufferLoad.f32(i32 68, %dx.types.Handle [[HANDLE]], i32 0, i32 undef) #[[#ATTR]]
  %data0 = call {<2 x float>, i1} @llvm.dx.resource.load.typedbuffer(
      target("dx.TypedBuffer", <2 x float>, 0, 0, 0) %buffer, i32 0)

  ret void
}

define void @loadv4f32_checkbit() {
  ; CHECK: [[BIND:%.*]] = call %dx.types.Handle @dx.op.createHandleFromBinding(i32 217,
  ; CHECK: [[HANDLE:%.*]] = call %dx.types.Handle @dx.op.annotateHandle(i32 216, %dx.types.Handle [[BIND]]
  %buffer = call target("dx.TypedBuffer", <4 x float>, 0, 0, 0)
      @llvm.dx.resource.handlefrombinding.tdx.TypedBuffer_v4f32_0_0_0(
          i32 0, i32 0, i32 1, i32 0, i1 false, ptr null)

  ; CHECK: [[DATA0:%.*]] = call %dx.types.ResRet.f32 @dx.op.bufferLoad.f32(i32 68, %dx.types.Handle [[HANDLE]], i32 0, i32 undef) #[[#ATTR]]
  %data0 = call {<4 x float>, i1} @llvm.dx.resource.load.typedbuffer.f32(
      target("dx.TypedBuffer", <4 x float>, 0, 0, 0) %buffer, i32 0)

  ; CHECK: [[STATUS:%.*]] = extractvalue %dx.types.ResRet.f32 [[DATA0]], 4
  ; CHECK: [[MAPPED:%.*]] = call i1 @dx.op.checkAccessFullyMapped.i32(i32 71, i32 [[STATUS]]) #[[#ATTR]]
  %check = extractvalue {<4 x float>, i1} %data0, 1

  ; CHECK: call void @check_user(i1 [[MAPPED]])
  call void @check_user(i1 %check)

  ret void
}

define void @loadv4i32() {
  ; CHECK: [[BIND:%.*]] = call %dx.types.Handle @dx.op.createHandleFromBinding(i32 217,
  ; CHECK: [[HANDLE:%.*]] = call %dx.types.Handle @dx.op.annotateHandle(i32 216, %dx.types.Handle [[BIND]]
  %buffer = call target("dx.TypedBuffer", <4 x i32>, 0, 0, 0)
      @llvm.dx.resource.handlefrombinding.tdx.TypedBuffer_v4i32_0_0_0(
          i32 0, i32 0, i32 1, i32 0, i1 false, ptr null)

  ; CHECK: [[DATA0:%.*]] = call %dx.types.ResRet.i32 @dx.op.bufferLoad.i32(i32 68, %dx.types.Handle [[HANDLE]], i32 0, i32 undef) #[[#ATTR]]
  %data0 = call {<4 x i32>, i1} @llvm.dx.resource.load.typedbuffer(
      target("dx.TypedBuffer", <4 x i32>, 0, 0, 0) %buffer, i32 0)

  ret void
}

define void @loadv4f16() {
  ; CHECK: [[BIND:%.*]] = call %dx.types.Handle @dx.op.createHandleFromBinding(i32 217,
  ; CHECK: [[HANDLE:%.*]] = call %dx.types.Handle @dx.op.annotateHandle(i32 216, %dx.types.Handle [[BIND]]
  %buffer = call target("dx.TypedBuffer", <4 x half>, 0, 0, 0)
      @llvm.dx.resource.handlefrombinding.tdx.TypedBuffer_v4f16_0_0_0(
          i32 0, i32 0, i32 1, i32 0, i1 false, ptr null)

  ; CHECK: [[DATA0:%.*]] = call %dx.types.ResRet.f16 @dx.op.bufferLoad.f16(i32 68, %dx.types.Handle [[HANDLE]], i32 0, i32 undef) #[[#ATTR]]
  %data0 = call {<4 x half>, i1} @llvm.dx.resource.load.typedbuffer(
      target("dx.TypedBuffer", <4 x half>, 0, 0, 0) %buffer, i32 0)

  ret void
}

define void @loadv4i16() {
  ; CHECK: [[BIND:%.*]] = call %dx.types.Handle @dx.op.createHandleFromBinding(i32 217,
  ; CHECK: [[HANDLE:%.*]] = call %dx.types.Handle @dx.op.annotateHandle(i32 216, %dx.types.Handle [[BIND]]
  %buffer = call target("dx.TypedBuffer", <4 x i16>, 0, 0, 0)
      @llvm.dx.resource.handlefrombinding.tdx.TypedBuffer_v4i16_0_0_0(
          i32 0, i32 0, i32 1, i32 0, i1 false, ptr null)

  ; CHECK: [[DATA0:%.*]] = call %dx.types.ResRet.i16 @dx.op.bufferLoad.i16(i32 68, %dx.types.Handle [[HANDLE]], i32 0, i32 undef) #[[#ATTR]]
  %data0 = call {<4 x i16>, i1} @llvm.dx.resource.load.typedbuffer(
      target("dx.TypedBuffer", <4 x i16>, 0, 0, 0) %buffer, i32 0)

  ret void
}

define void @loadf64() {
  ; show dxil op lower can handle typedbuffer load where target is double but load type is <2 x i32>
  ; CHECK: [[B1:%.*]] = call %dx.types.Handle @dx.op.createHandleFromBinding(i32 217, %dx.types.ResBind { i32 1, i32 1, i32 0, i8 1 }, i32 1, i1 false) #0
  %buffer = call target("dx.TypedBuffer", double, 1, 0, 0)
      @llvm.dx.resource.handlefrombinding.tdx.TypedBuffer_f64_1_0_0t(
          i32 0, i32 1, i32 1, i32 0, i1 false, ptr null)

  ; CHECK: [[BA:%.*]] = call %dx.types.Handle @dx.op.annotateHandle(i32 216, %dx.types.Handle [[B1]], %dx.types.ResourceProperties { i32 4106, i32 266 }) #0
  %load = call { <2 x i32>, i1 } @llvm.dx.resource.load.typedbuffer(
      target("dx.TypedBuffer", double, 1, 0, 0) %buffer, i32 0)

; CHECK: call %dx.types.ResRet.i32 @dx.op.bufferLoad.i32(i32 68, %dx.types.Handle [[BA]], i32 0, i32 undef) #1
  %val = extractvalue { <2 x i32>, i1 } %load, 0
  ret void
}

define void @loadv2f64() {
  ; show dxil op lower can handle typedbuffer load where target is double2 but load type is <4 x i32>
  ; CHECK: [[B1:%.*]] = call %dx.types.Handle @dx.op.createHandleFromBinding(i32 217, %dx.types.ResBind { i32 1, i32 1, i32 0, i8 1 }, i32 1, i1 false) #0
  %buffer = call target("dx.TypedBuffer", <2 x double>, 1, 0, 0)
      @llvm.dx.resource.handlefrombinding.tdx.TypedBuffer_v2f64_1_0_0t(
          i32 0, i32 1, i32 1, i32 0, i1 false, ptr null)

  ; CHECK: [[BA:%.*]] = call %dx.types.Handle @dx.op.annotateHandle(i32 216, %dx.types.Handle [[B1]], %dx.types.ResourceProperties { i32 4106, i32 522 }) #0
  %load = call { <4 x i32>, i1 } @llvm.dx.resource.load.typedbuffer(
      target("dx.TypedBuffer", <2 x double>, 1, 0, 0) %buffer, i32 0)

  ; CHECK: call %dx.types.ResRet.i32 @dx.op.bufferLoad.i32(i32 68, %dx.types.Handle [[BA]], i32 0, i32 undef) #1
  %val = extractvalue { <4 x i32>, i1 } %load, 0
  ret void
}

; CHECK: attributes #[[#ATTR]] = {{{.*}} memory(read) {{.*}}}
