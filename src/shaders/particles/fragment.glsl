varying vec3 vColor;

void main()
{

    vec2 uv = gl_PointCoord;
 
    // なぜか中心に向かって０になる
    // はじは0.5
    float distanceToCenter = length(uv - 0.5);
    // 同じく
    // float distanceToCenter = distance(uv, vec2(0.5));

    // 0.05　/ ハジに向かって数字が大きくなる数
    // 中心に向かって急速に1になる（0.05まで）
    // 最後に減算してハジを縮めることで円の輪郭が出る
    // float alpha = 0.05 / distanceToCenter - 0.1; 
    
    float alpha = smoothstep(0.5, 0.45, distanceToCenter);
    if (distanceToCenter > 0.5) {
        alpha = 0.0;  // 外側は完全に透明
    } else {
        alpha = 1.0;  // 内側は透明度なし
    }

    // gl_FragColor = vec4(1.0, 1.0, 1.0, alpha);
    gl_FragColor = vec4(vColor, alpha);
    
    #include <tonemapping_fragment>
    #include <colorspace_fragment>
}