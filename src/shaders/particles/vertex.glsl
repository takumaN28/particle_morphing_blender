uniform vec2 uResolution;
uniform float uSize;
uniform float uProgress;
uniform float uTime;
attribute vec3 aPositionTarget;
attribute float aSize;
attribute vec4 aColor;
attribute vec4 aColorTarget;

varying vec4 vColor;

#include ../includes/simplexNoise3d.glsl


// 乱数
float random(float seed) {
    return fract(sin(seed) * 43758.5453123);
}

// 偏りのある乱数を生成する関数
float biasedRandom(float seed) {
    float rnd = random(seed);
    return pow(rnd, 3.0);  // ここで3乗して小さい値と大きい値に偏らせる
}

void main()
{
    // パーティクルごとに異なるランダムな揺らぎの強度を生成
    float amplitude = biasedRandom(position.x + position.y + position.z) * 0.2;

    // パーティクルの位置を時間と共にオフセット
    vec3 aPositionOffset = aPositionTarget + vec3(
        sin(position.x * 10.0 + uTime) * amplitude,
        cos(position.y * 10.0 + uTime) * amplitude,
        sin(position.z * 10.0 + uTime) * amplitude
    );

    // mixed position
    float noiseOrigin = simplexNoise3d(position * 0.2);
    float noiseTarget = simplexNoise3d(aPositionOffset * 0.2);
    float noise = mix(noiseOrigin, noiseTarget, uProgress); //progressが進むにつれて元のpositionと後のpositionが混ざるようにすることで始まりと終わりにnoiseがかかる
    noise = smoothstep(-1.0, 1.0, noise); // 与えられた範囲で動く

    float duration = 0.4; // アニメーションの時間
    float delay = (1.0 - duration) * noise; //始まるまでの遅れ 1.0で終わるのでそこからアニメーション時間を引く。 noiseは1.0/-1.0の間で出るのでそれで調整
    float end = delay + duration;

    float progress = smoothstep(delay, end, uProgress); //
    vec3 mixedPosition = mix(position, aPositionOffset, progress); //現在表示してるpositionと次のaPositionTargetとをprogressでmixさせる

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
    vec4 currentColor = aColor;
    vec4 targetColor = aColorTarget;
    vec4 mixColor =  mix(currentColor, targetColor, progress);
    vColor = mixColor; // で頂点カラーから設定
    
}