uniform vec2 uResolution;
uniform float uSize;
uniform float uProgress;
attribute vec3 aPositionTarget;
attribute float aSize;
attribute vec3 aColor;
attribute vec3 aColorTarget;

varying vec3 vColor;

#include ../includes/simplexNoise3d.glsl

void main()
{

    // mixed position
    float noiseOrigin = simplexNoise3d(position * 0.2);
    float noiseTarget = simplexNoise3d(aPositionTarget * 0.2);
    float noise = mix(noiseOrigin, noiseTarget, uProgress); //progressが進むにつれて元のpositionと後のpositionが混ざるようにすることで始まりと終わりにnoiseがかかる
    noise = smoothstep(-1.0, 1.0, noise); // 与えられた範囲で動く

    float duration = 0.4; // アニメーションの時間
    float delay = (1.0 - duration) * noise; //始まるまでの遅れ 1.0で終わるのでそこからアニメーション時間を引く。 noiseは1.0/-1.0の間で出るのでそれで調整
    float end = delay + duration;

    float progress = smoothstep(delay, end, uProgress); //
    vec3 mixedPosition = mix(position, aPositionTarget, progress); //現在表示してるpositionと次のaPositionTargetとをprogressでmixさせる

    // Final position
    vec4 modelPosition = modelMatrix * vec4(mixedPosition, 1.0);
    vec4 viewPosition = viewMatrix * modelPosition;
    vec4 projectedPosition = projectionMatrix * viewPosition;
    gl_Position = projectedPosition;

    // Point size
    gl_PointSize = aSize * uSize * uResolution.y;
    gl_PointSize *= (1.0 / - viewPosition.z);


    // Color
    // Varying
    // vColor = mix(uColorA,uColorB,noise);
    vec3 currentColor = aColor;
    vec3 targetColor = aColorTarget;
    vec3 mixColor =  mix(currentColor, targetColor, progress);
    vColor = mixColor; // で頂点カラーから設定
    
}