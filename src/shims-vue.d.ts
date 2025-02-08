// I have no idea why I need to do this after initting the repo
// but I do, so I'm just going to leave this here
declare module '*.vue' {
  import type { DefineComponent } from 'vue'
  const component: DefineComponent<Record<string, unknown>, Record<string, unknown>, unknown>
  export default component
}
