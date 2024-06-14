import * as THREE from 'three'
import { OrbitControls } from 'three/addons/controls/OrbitControls.js'
import { GLTFLoader } from 'three/addons/loaders/GLTFLoader.js'
import { DRACOLoader } from 'three/addons/loaders/DRACOLoader.js'
import GUI from 'lil-gui'
import gsap from 'gsap'
import particlesVertexShader from './shaders/particles/vertex.glsl'
import particlesFragmentShader from './shaders/particles/fragment.glsl'

/**
 * Base
 */
// Debug
const gui = new GUI({ width: 340 })
const debugObject = {}

// Canvas
const canvas = document.querySelector('canvas.webgl')

// Scene
const scene = new THREE.Scene()

// Loaders
const dracoLoader = new DRACOLoader()
dracoLoader.setDecoderPath('./draco/')
const gltfLoader = new GLTFLoader()
gltfLoader.setDRACOLoader(dracoLoader)

/**
 * Sizes
 */
const sizes = {
    width: window.innerWidth,
    height: window.innerHeight,
    pixelRatio: Math.min(window.devicePixelRatio, 2)
}

window.addEventListener('resize', () =>
{
    // Update sizes
    sizes.width = window.innerWidth
    sizes.height = window.innerHeight
    sizes.pixelRatio = Math.min(window.devicePixelRatio, 2)

    // Materials
    if(particles){
        particles.material.uniforms.uResolution.value.set(sizes.width * sizes.pixelRatio, sizes.height * sizes.pixelRatio)
    }

    // Update camera
    camera.aspect = sizes.width / sizes.height
    camera.updateProjectionMatrix()

    // Update renderer
    renderer.setSize(sizes.width, sizes.height)
    renderer.setPixelRatio(sizes.pixelRatio)
})

/**
 * Camera
 */
// Base camera
const camera = new THREE.PerspectiveCamera(35, sizes.width / sizes.height, 0.1, 100)
camera.position.set(0, 0, 8 * 2)
scene.add(camera)

// Controls
const controls = new OrbitControls(camera, canvas)
controls.enableDamping = true

/**
 * Renderer
 */
const renderer = new THREE.WebGLRenderer({
    canvas: canvas,
    antialias: true,
})

renderer.setSize(sizes.width, sizes.height)
renderer.setPixelRatio(sizes.pixelRatio)

debugObject.clearColor = '#160920'
gui.addColor(debugObject, 'clearColor').onChange(() => { renderer.setClearColor(debugObject.clearColor) })
renderer.setClearColor(debugObject.clearColor)

/**
 * Particles
 */

let particles = null

//load models
// gltfLoader.load('./models.glb', (gltf)=>{
    // gltfLoader.load('./nadia.glb', (gltf) => {
    // gltfLoader.load('./boats.glb', (gltf) => {
    gltfLoader.load('./text.glb', (gltf) => {
        particles = {};
        particles.index = 0;
    
    
        const positions = gltf.scene.children.map((child) => {
            // console.log('position', child.geometry.attributes.position)
            return child.geometry.attributes.position;
        });
    
        const colors = gltf.scene.children.map((child) => {
            // console.log('color', child.geometry.attributes.color)
            return child.geometry.attributes.color;
        });
    
        particles.maxCount = 0;
        for (const position of positions) {
            if (position.count > particles.maxCount) {
                particles.maxCount = position.count;
            }
        }
    
        particles.positions = [];
        particles.colors = [];
        for (const [index, position] of positions.entries()) {
            const originalArray = position.array;
            const newArray = new Float32Array(particles.maxCount * 3);
    
            const originalColorArray = colors[index].array;
            // console.log('originalColorArray',originalColorArray)
            const newColorArray = new Uint16Array(particles.maxCount * 4);
            // console.log('newColorArray',newColorArray)
    
            for (let i = 0; i < particles.maxCount; i++) {
                const i3 = i * 3;
                const i4 = i * 4;
                if (i3 < originalArray.length) {
                    newArray[i3 + 0] = originalArray[i3 + 0] + (Math.random() * 0.8);
                    newArray[i3 + 1] = originalArray[i3 + 1] + (Math.random() * 0.8);
                    newArray[i3 + 2] = originalArray[i3 + 2] + (Math.random() * 0.8);
    
                    newColorArray[i4 + 0] = originalColorArray[i4 + 0];
                    newColorArray[i4 + 1] = originalColorArray[i4 + 1];
                    newColorArray[i4 + 2] = originalColorArray[i4 + 2];
                    newColorArray[i4 + 3] = originalColorArray[i4 + 3];
                } else {
                    const positionRandomIndex = Math.floor(position.count * Math.random()) * 3;
                    const colorRandomIndex = Math.floor(originalColorArray.length * Math.random()) * 4;
                    
                    newArray[i3 + 0] = originalArray[positionRandomIndex + 0];
                    newArray[i3 + 1] = originalArray[positionRandomIndex + 1];
                    newArray[i3 + 2] = originalArray[positionRandomIndex + 2];
    
                    newColorArray[i4 + 0] = originalColorArray[colorRandomIndex + 0];
                    newColorArray[i4 + 1] = originalColorArray[colorRandomIndex + 1];
                    newColorArray[i4 + 2] = originalColorArray[colorRandomIndex + 2];
                    newColorArray[i4 + 3] = originalColorArray[colorRandomIndex + 3];
                }
            }
    
            particles.positions.push(new THREE.Float32BufferAttribute(newArray, 3));
            const editParticleColorArray = new THREE.BufferAttribute(newColorArray, 4)
            editParticleColorArray.normalized = true
            particles.colors.push(editParticleColorArray);
        }

    

        // Geometry
        const sizesArray = new Float32Array(particles.maxCount);
        for (let i = 0; i < particles.maxCount; i++) {
            sizesArray[i] = Math.random();
        }

        
        particles.geometry = new THREE.BufferGeometry();

        particles.geometry.setAttribute('position', particles.positions[particles.index]);
        particles.geometry.setAttribute('aPositionTarget', particles.positions[1]);

        particles.geometry.setAttribute('aSize', new THREE.BufferAttribute(sizesArray, 1));

        particles.geometry.setAttribute('aColor', particles.colors[particles.index]);
        // particles.geometry.setAttribute('aColor', colors[particles.index]);//一旦直接入れる方法もある
        // console.log( particles.colors)
        particles.geometry.setAttribute('aColorTarget', particles.colors[1]);
 

        // Material
        particles.material = new THREE.ShaderMaterial({
            vertexShader: particlesVertexShader,
            fragmentShader: particlesFragmentShader,
            uniforms: {
                uSize: new THREE.Uniform(0.1),
                uResolution: new THREE.Uniform(new THREE.Vector2(sizes.width * sizes.pixelRatio, sizes.height * sizes.pixelRatio)),
                uProgress: new THREE.Uniform(0),
                // uColorA: new THREE.Uniform(new THREE.Color(particles.colorA)),
                // uColorB: new THREE.Uniform(new THREE.Color(particles.colorB)),
            },
            vertexColors: true,
            depthWrite: false,
            transparent: true,
        });
    
        // Points
        particles.points = new THREE.Points(particles.geometry, particles.material);
        particles.points.frustumCulled = false;
        scene.add(particles.points);
        

        // Methods
        particles.morph = (index) => {
            particles.geometry.attributes.position = particles.positions[particles.index];
            particles.geometry.attributes.aPositionTarget = particles.positions[index];
            particles.geometry.attributes.aColor = particles.colors[index];
       
            gsap.fromTo(
                particles.material.uniforms.uProgress,
                { value: 0 },
                { value: 1, duration: 3, ease: 'linear' }
            );
            particles.index = index;
          
        };


        gui.add(particles.material.uniforms.uProgress, 'value').min(0).max(1).step(0.001).name('uProgress');
        // gui.addColor(particles, 'colorA').onChange(() => { particles.material.uniforms.uColorA.value.set(particles.colorA) });
        // gui.addColor(particles, 'colorB').onChange(() => { particles.material.uniforms.uColorB.value.set(particles.colorB) });
    
        particles.morph0 = () => { particles.morph(0) };
        particles.morph1 = () => { particles.morph(1) };
        // particles.morph2 = () => { particles.morph(2) };
        // particles.morph3 = () => { particles.morph(3) };
    
        gui.add(particles, 'morph0');
        gui.add(particles, 'morph1');
        // gui.add(particles, 'morph2');
        // gui.add(particles, 'morph3');
    });
    


/**
 * Animate
 */
const tick = () =>
{
    // Update controls
    controls.update()

    // Render normal scene
    renderer.render(scene, camera)

    // Call tick again on the next frame
    window.requestAnimationFrame(tick)
}

tick()