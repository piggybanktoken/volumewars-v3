import { drizzleReactHooks, drizzleConnect } from '@drizzle/react-plugin'
import Loading from './Loading'

    const mapStateToProps = (state: any) => {
        return {
            drizzleStatus: state.drizzleStatus,
            web3: state.web3
        }
    }
  
  const LoadingContainer = drizzleConnect(Loading, mapStateToProps);
  
  export default LoadingContainer