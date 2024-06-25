uniform vec2 uResolution;
uniform float uSize;
uniform float uProgress;
uniform float uTime;
attribute vec3 aPositionTarget;
attribute float aSize;
attribute vec4 aColor;
attribute vec4 aColorTarget;

varying vec4 vColor;

#include "../includes/simplexNoise3d.glsl"

// // 乱数
// float random(float seed) {
//     return fract(sin(seed) * 43758.5453123);
// }

// // 偏りのある乱数を生成する関数
// float biasedRandom(float seed) {
//     float rnd = random(seed);
//     return pow(rnd, 6.0);  // 小さい値と大きい値に偏らせる
// }

void main()
{
    // // パーティクルごとに異なるランダムな揺らぎの強度を生成
    // float randomSeed = random(position.x + position.y + position.z);
    // float amplitude = pow(randomSeed, 6.0) * 0.2; // 揺らぎの強度をランダムに決定

    // // 現在のランダムなオフセット位置
    // vec3 positionOffset = position + vec3(
    //     sin(position.x * 10.0 + uTime) * amplitude,
    //     cos(position.y * 10.0 + uTime) * amplitude,
    //     sin(position.z * 10.0 + uTime) * amplitude
    // );

    // // 開始時と終了時の目標位置
    // vec3 startTargetOffset = aPositionTarget + vec3(
    //     sin(position.x * 10.0 + uTime) * amplitude,
    //     cos(position.y * 10.0 + uTime) * amplitude,
    //     sin(position.z * 10.0 + uTime) * amplitude
    // );
    // vec3 endTargetOffset = aPositionTarget; // 切り替え後の目標位置

    // // 目標位置の補間
    // vec3 targetOffset = mix(startTargetOffset, endTargetOffset, smoothstep(0.0, 1.0, uProgress));

    // ノイズの計算
    float noiseOrigin = simplexNoise3d(position * 0.2);
    float noiseTarget = simplexNoise3d(aPositionTarget * 0.2);
    float noise = mix(noiseOrigin, noiseTarget, uProgress);
    noise = smoothstep(-1.0, 1.0, noise);

    // アニメーションのタイミング調整
    float duration = 0.4; // アニメーションの時間
    float delay = (1.0 - duration) * noise;
    float end = delay + duration;

    float progress = smoothstep(delay, end, uProgress);
    vec3 mixedPosition = mix(position, aPositionTarget, progress); // 現在位置と目標位置の補間

    // 最終的な位置計算
    vec4 modelPosition = modelMatrix * vec4(mixedPosition, 1.0);
    vec4 viewPosition = viewMatrix * modelPosition;
    vec4 projectedPosition = projectionMatrix * viewPosition;
    gl_Position = projectedPosition;

    // ポイントサイズ
    gl_PointSize = aSize * uSize * uResolution.y;
    gl_PointSize *= (1.0 / -viewPosition.z);

    // カラーの計算
    vec4 currentColor = aColor;
    vec4 targetColor = aColorTarget;
    vec4 mixColor = mix(currentColor, targetColor, progress);
    vColor = mixColor; // 頂点カラーを設定
}
