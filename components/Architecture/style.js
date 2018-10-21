import styled from 'styled-components'

export const Wrapper = styled.div`
    height: 800px;
    width: 100%;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    p {
        font-family: Avenir Next, sans-serif;

    }

`;

export const ClientImageWrapper = styled.img`
    position: absolute;
    grid-area: image;
    bottom: ${props => props.selected ? 0 : -1}%;
    filter: ${props => props.selected ? `drop-shadow(0 3px 2px rgb(85, 72, 132)) drop-shadow(0 2px 2px rgb(85, 72, 132))` : `none`};
    &:hover {
        bottom: -1%;
        filter: drop-shadow(0 3px 2px rgb(85, 72, 132)) drop-shadow(0 2px 2px rgb(85, 72, 132));
    }
`;
export const ClientLabel = styled.div`
    position: absolute;
    color: white;
    background: black;
    padding: 10px;
    bottom: 4%;
    right: 3%;
    display: ${props => props.selected ? `block` : `none`};
    p {
        margin: 0 20px 0 20px;
    }
`;
export const BackgroundImageWrapper = styled.img`
    position: absolute;
    filter: ${props => props.selected ? `drop-shadow(0 3px 2px rgb(85, 72, 132)) drop-shadow(0 2px 2px rgb(85, 72, 132))` : `none`};
    &:hover {
        filter: drop-shadow(0 3px 2px rgb(85, 72, 132)) drop-shadow(0 2px 2px rgb(85, 72, 132));
    }
`;
export const BackgroundLabel = styled.div`
    position: absolute;
    color: white;
    background: black;
    top: 20%;
    right: -10%;
    display: ${props => props.selected ? `block` : `none`};
    p {
        margin: 0 20px 0 20px;
    }

`;
export const MicroservicesImageWrapper = styled.img`
    position: absolute;
    filter: ${props => props.selected ? `drop-shadow(0 3px 2px rgb(85, 72, 132)) drop-shadow(0 2px 2px rgb(85, 72, 132))` : `none`};
    &:hover {
        filter: drop-shadow(0 3px 2px rgb(85, 72, 132)) drop-shadow(0 2px 2px rgb(85, 72, 132));
    }
`;
export const MicroservicesLabel = styled.div`
    position: absolute;
    top: 30%;
    right: 5%;
    color: white;
    background: black;
    display: ${props => props.selected ? `block` : `none`};
    p {
        margin: 0 20px 0 20px;
    }
`;
export const IngressImageWrapper = styled.img`
    position: absolute;
    top: 59%;
    filter: ${props => props.selected ? `drop-shadow(0 3px 2px rgb(85, 72, 132)) drop-shadow(0 2px 2px rgb(85, 72, 132))` : `none`};
    &:hover {
        filter: drop-shadow(0 3px 2px rgb(85, 72, 132)) drop-shadow(0 2px 2px rgb(85, 72, 132));
    }
`;
export const IngressLabel = styled.div`
    position: absolute;
    top: 67%;
    right: 5%;
    color: white;
    background: black;
    display: ${props => props.selected ? `block` : `none`};
    p {
        margin: 0 20px 0 20px;
    }

`;
